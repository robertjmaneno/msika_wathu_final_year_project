class VendorUserModel {
  final bool? approved;
  final String? vendorId;
  final String? businessName;
  final String? country;
  final String? city;
  final String? TA;
  final String? email;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isSeller;

  VendorUserModel(
      {required this.approved,
      required this.vendorId,
      required this.businessName,
      required this.country,
      required this.city,
      required this.TA,
      required this.email,
      required this.fullName,
      required this.phoneNumber,
      required this.isSeller,
      required this.profileImageUrl});

  VendorUserModel.fromJson(Map<String, dynamic> json)
      : this(
          approved: json['approved']! as bool,
          isSeller: json['isSeller']! as bool,
          businessName: json['businessName']! as String,
          vendorId: json['vendorId']! as String,
          country: json['country']! as String,
          city: json['city']! as String,
          TA: json['TA']! as String,
          email: json['email']! as String,
          fullName: json['fullName']! as String,
          phoneNumber: json['phoneNumber']! as String,
          profileImageUrl: json['profileImageUrl']! as String,
        );

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'approved': approved,
      'businessName': businessName,
      'vendorId': vendorId,
      'city': city,
      'country': country,
      'TA': TA,
      'isSeller': isSeller,
    };
  }
}
