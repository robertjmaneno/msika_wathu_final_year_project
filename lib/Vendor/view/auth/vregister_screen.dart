import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/controllers/vauth_controller.dart';
import 'package:msika_wathu/Vendor/custom_widgets/admin_appBar.dart';
import 'package:msika_wathu/Vendor/view/auth/vloging_screan.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

class VRegisterScreen extends StatefulWidget {
  const VRegisterScreen({super.key, Key});

  @override
  _VRegisterScreenState createState() => _VRegisterScreenState();
}

class _VRegisterScreenState extends State<VRegisterScreen> {
  final AuthController _authController = AuthController();
  String email = '';
  String fullName = '';
  String phoneNumber = '';
  String password = '';
  String confirmPassword = '';
  String businessName = '';
  String city = '';
  String TA = '';
  String country = '';
  XFile? globalImage;
  bool isSeller = true;
  bool approved = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  PasswordStrength passwordStrength = PasswordStrength.none;
  bool passwordsMatch = false;
  bool isLoading = false; // Track loading state

  _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      if (password == confirmPassword) {
        setState(() {
          isLoading = true; // set loading state to true
        });

        String result = await _authController.signUpUsers(
          email,
          fullName,
          phoneNumber,
          password,
          isSeller,
          businessName,
          approved,
          country,
          city,
          TA,
        );

        if (result == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VLoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: $result'),
              backgroundColor: Colors.red,
            ),
          );
        }

        setState(() {
          isLoading = false; // Set loading state to false
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  PasswordStrength calculatePasswordStrength(String value) {
    bool hasUppercase = false;
    bool hasLowercase = false;
    bool hasSymbol = false;
    bool hasNumber = false;

    for (var char in value.runes) {
      if (char >= 65 && char <= 90) {
        hasUppercase = true;
      } else if (char >= 97 && char <= 122) {
        hasLowercase = true;
      } else if ((char >= 33 && char <= 47) || (char >= 58 && char <= 64)) {
        hasSymbol = true;
      } else if (char >= 48 && char <= 57) {
        hasNumber = true;
      }
    }

    int score = 0;

    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasSymbol) score++;
    if (hasNumber) score++;

    if (value.length < 6) {
      return PasswordStrength.weak;
    }

    if (score >= 4) {
      return PasswordStrength.strong;
    }

    if (score >= 2) {
      return PasswordStrength.medium;
    }

    return PasswordStrength.weak;
  }

  selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog first

                    // Show a loading indicator
                    showLoadingDialog(context);

                    final img = await _authController.imagePicker(
                      context,
                      ImageSource.camera,
                    );

                    // Dismiss the loading indicator
                    Navigator.of(context, rootNavigator: true).pop();

                    if (img != null) {
                      setState(() {
                        globalImage = img;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Camera',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog first

                    // Show a loading indicator
                    showLoadingDialog(context);

                    final img = await _authController.imagePicker(
                      context,
                      ImageSource.gallery,
                    );

                    // Dismiss the loading indicator
                    Navigator.of(context, rootNavigator: true).pop();

                    if (img != null) {
                      setState(() {
                        globalImage = img;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Gallery',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Function to show a loading indicator
  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(75.0), // Adjust the height as needed,
        child: AdminAppBar(
          title: 'Creating an account',
          imagePath: 'assets/images/register.png',
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            fullName = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            businessName = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Business Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.business),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            country = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Your Country',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.location_on),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            city = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Your City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.location_city),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            TA = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Traditional Authority',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.business_center),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      phoneNumber = value;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Phone Number',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    prefixIcon: const Icon(Icons.phone),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          // Trim leading and trailing whitespaces
                          final trimmedValue = value.trim();
                          setState(() => email = trimmedValue);
                        },
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.email),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          if (!isValidEmail(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            password = value;
                            if (value.isNotEmpty) {
                              passwordStrength =
                                  calculatePasswordStrength(value);
                            } else {
                              passwordStrength = PasswordStrength.none;
                            }
                            passwordsMatch = password == confirmPassword;
                          });
                        },
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must have at least 6 characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            confirmPassword = value;
                            passwordsMatch = password == confirmPassword;
                          });
                        },
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          suffix: passwordsMatch
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : confirmPassword.isNotEmpty
                                  ? const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    )
                                  : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != password) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          confirmPassword = value!;
                        },
                      ),
                    ],
                  ),
                ),
                if (password.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: LinearProgressIndicator(
                      value: passwordStrength == PasswordStrength.none
                          ? 0.0
                          : passwordStrength == PasswordStrength.weak
                              ? 0.33
                              : passwordStrength == PasswordStrength.medium
                                  ? 0.66
                                  : 1.0,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        passwordStrength == PasswordStrength.none
                            ? Colors.grey
                            : passwordStrength == PasswordStrength.weak
                                ? Colors.red
                                : passwordStrength == PasswordStrength.medium
                                    ? Colors.orange
                                    : Colors.green,
                      ),
                    ),
                  ),
                if (password.isNotEmpty) const SizedBox(height: 8),
                if (password.isNotEmpty)
                  Text(
                    passwordStrength == PasswordStrength.none
                        ? 'None'
                        : passwordStrength == PasswordStrength.weak
                            ? 'Weak'
                            : passwordStrength == PasswordStrength.medium
                                ? 'Medium'
                                : 'Strong',
                    style: TextStyle(
                      color: passwordStrength == PasswordStrength.none
                          ? Colors.grey
                          : passwordStrength == PasswordStrength.weak
                              ? Colors.red
                              : passwordStrength == PasswordStrength.medium
                                  ? Colors.orange
                                  : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _signUpUser();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Already a member?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return const VLoginScreen();
                          }),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Login',
                          ),
                          Icon(Icons.login),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }
}

enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}

class _CountrySelect extends StatefulWidget {
  @override
  __CountrySelectState createState() => __CountrySelectState();
}

class __CountrySelectState extends State<_CountrySelect> {
  String? _selectedCountry = 'Malawi (+265)';

  void _showCountryMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'Malawi (+265)',
          child: Text('Malawi (+265)'),
        ),
        const PopupMenuItem<String>(
          value: 'Nigeria (+234)',
          child: Text('Nigeria (+234)'),
        ),
        const PopupMenuItem<String>(
          value: 'Kenya (+254)',
          child: Text('Kenya (+254)'),
        ),
        const PopupMenuItem<String>(
          value: 'South Africa (+27)',
          child: Text('South Africa (+27)'),
        ),
        const PopupMenuItem<String>(
          value: 'Ghana (+233)',
          child: Text('Ghana (+233)'),
        ),
        const PopupMenuItem<String>(
          value: 'Egypt (+20)',
          child: Text('Egypt (+20)'),
        ),
      ],
    ).then<void>((String? value) {
      if (value != null) {
        setState(() {
          _selectedCountry = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showCountryMenu(context);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Country Code',
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_selectedCountry!),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
