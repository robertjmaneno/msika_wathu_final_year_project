import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String userId;
  final String username;
  final String profileImageUrl;
  final bool isSeller;

  ChatUser({
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.isSeller,
  });
}

class Message {
  final String text;
  final String senderId;
  final DateTime? timestamp;

  Message({
    required this.text,
    required this.senderId,
    this.timestamp,
  });
}

class BuyerChatWidget extends StatefulWidget {
  const BuyerChatWidget({Key? key}) : super(key: key);

  @override
  _BuyerChatWidgetState createState() => _BuyerChatWidgetState();
}

class _BuyerChatWidgetState extends State<BuyerChatWidget> {
  final List<ChatUser> _chatUsers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(); // Add await here
    final token = await fcm.getToken(); // Add await here
    print(token);
  }

  @override
  void initState() {
    super.initState();
    _loadChatUsers();
    setupPushNotifications;
  }

  Future<void> _loadChatUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();

      final chatUsers =
          querySnapshot.docs.where((doc) => doc['isSeller'] == true).map((doc) {
        final userId = doc.id;
        final username = doc['fullName'] ?? 'No Name';
        final profileImageUrl = doc['profileImageUrl'] ?? 'No Image URL';
        final isSeller = doc['isSeller'] ?? false;

        return ChatUser(
          userId: userId,
          username: username,
          profileImageUrl: profileImageUrl,
          isSeller: isSeller,
        );
      }).toList();

      setState(() {
        _chatUsers.addAll(chatUsers);
      });
    } catch (e) {
      // Handle and log the error
      print('Error loading chat users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          'Chat Messages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _chatUsers.isEmpty
          ? const Center(
              child: Text(
                'You do not have any\nmessage at the momemt',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _chatUsers.length,
              itemBuilder: (BuildContext context, int index) {
                final chatUser = _chatUsers[index];
                return StreamBuilder<int>(
                  stream: _getUnreadMessagesCountStream(chatUser),
                  builder: (context, snapshot) {
                    final unreadMessagesCount = snapshot.data ?? 0;
                    return ChatUserTile(
                      chatUser: chatUser,
                      unreadMessagesCount: unreadMessagesCount,
                    );
                  },
                );
              },
            ),
    );
  }

  Stream<int> _getUnreadMessagesCountStream(ChatUser chatUser) {
    final user = _auth.currentUser;
    if (user != null) {
      final chatRoomId = _getChatRoomId(user.uid, chatUser.userId);

      final chatCollectionRef =
          _firestore.collection('messages').doc(chatRoomId).collection('chats');

      // Create a Firestore stream that listens for new unread messages
      return chatCollectionRef
          .where('read',
              isEqualTo:
                  false) // Assuming there's a 'read' field in the messages
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    }

    return Stream.value(0); // Return a default value if user is null
  }

  String _getChatRoomId(String user1Id, String user2Id) {
    return user1Id.hashCode <= user2Id.hashCode
        ? '$user1Id-$user2Id'
        : '$user2Id-$user1Id';
  }
}

class ChatUserTile extends StatelessWidget {
  final ChatUser chatUser;
  final int unreadMessagesCount;

  const ChatUserTile({
    Key? key,
    required this.chatUser,
    required this.unreadMessagesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, // You can adjust the card elevation as needed
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(chatUser.profileImageUrl),
        ),
        title: Text(chatUser.username),
        trailing: unreadMessagesCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadMessagesCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          // Navigate to the chat screen with the selected seller
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatUser: chatUser,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final ChatUser chatUser;

  const ChatScreen({
    Key? key,
    required this.chatUser,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _messageStream;
  StreamSubscription<QuerySnapshot>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _messageStream = _getMessageStream();
    _streamSubscription = _messageStream?.listen((snapshot) {
      // Handle stream updates here
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Stream<QuerySnapshot> _getMessageStream() {
    final user = _auth.currentUser;
    if (user != null) {
      final chatRoomId = _getChatRoomId(user.uid, widget.chatUser.userId);

      final chatCollectionRef =
          _firestore.collection('messages').doc(chatRoomId).collection('chats');

      return chatCollectionRef
          .orderBy('timestamp')
          .snapshots()
          .handleError((error) {
        print("Error creating message stream: $error");
      });
    }

    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          widget.chatUser.username,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                List<ChatBubble> messageWidgets = [];

                for (var message in messages) {
                  final data = message.data() as Map<String, dynamic>;

                  // Check if the 'text' and 'senderId' fields exist in the document
                  if (data.containsKey('text') &&
                      data.containsKey('senderId')) {
                    final text = data['text'] as String;
                    final senderId = data['senderId'] as String;
                    final timestamp =
                        (data['timestamp'] as Timestamp?)?.toDate();

                    final messageWidget = ChatBubble(
                      message: Message(
                        text: text,
                        senderId: senderId,
                        timestamp: timestamp,
                      ),
                      isMe: senderId == _auth.currentUser?.uid,
                    );

                    messageWidgets.add(messageWidget);
                  }
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.jumpTo(
                    _scrollController.position.maxScrollExtent,
                  );
                });

                return ListView(
                  controller: _scrollController,
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getChatRoomId(String user1Id, String user2Id) {
    return user1Id.hashCode <= user2Id.hashCode
        ? '$user1Id-$user2Id'
        : '$user2Id-$user1Id';
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        final chatRoomId = _getChatRoomId(user.uid, widget.chatUser.userId);

        _firestore
            .collection('messages')
            .doc(chatRoomId)
            .collection('chats')
            .add({
          'text': text,
          'senderId': user.uid,
          'timestamp': FieldValue.serverTimestamp(), // Set the timestamp here
        });

        _textController.clear();
      }
    }
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timestamp = message.timestamp;
    final formattedTimestamp = timestamp != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toLocal())
        : 'Timestamp not available';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? const Color.fromARGB(255, 233, 232, 232)
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              formattedTimestamp,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
