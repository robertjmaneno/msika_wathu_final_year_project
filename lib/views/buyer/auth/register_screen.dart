import 'package:flutter/material.dart';
import 'package:msika_wathu/Vendor/custom_widgets/admin_appBar.dart';
import 'package:msika_wathu/controllers/auth_controller.dart';
import 'package:msika_wathu/views/buyer/auth/loging_screan.dart';
import 'package:msika_wathu/views/buyer/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();
  String email = '';
  String fullName = '';
  String phoneNumber = '';
  String password = '';
  String confirmPassword = '';

  bool isSeller = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  PasswordStrength passwordStrength = PasswordStrength.none;
  bool passwordsMatch = false;
  bool isLoading = false; // Track loading state

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  onChanged: (value) => setState(() => fullName = value),
                  decoration: const InputDecoration(
                    labelText: 'Enter Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Phone Number Field
                TextFormField(
                  onChanged: (value) => setState(() => phoneNumber = value),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Phone number must have at least 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Email Field
                // Email Field
                TextFormField(
                  onChanged: (value) {
                    // Trim leading and trailing whitespaces
                    final trimmedValue = value.trim();
                    setState(() => email = trimmedValue);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Email',
                    border: OutlineInputBorder(),
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
                ),

                const SizedBox(height: 10),

                // Password Field
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      password = value;
                      passwordStrength = calculatePasswordStrength(value);
                      passwordsMatch = password == confirmPassword;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => isPasswordVisible = !isPasswordVisible),
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must have at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Confirm Password Field
// Confirm Password Field
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      confirmPassword = value;
                      passwordsMatch = password == confirmPassword;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffix: passwordsMatch
                        ? const Icon(
                            Icons.check,
                            color: const Color(0xFF009689),
                          )
                        : confirmPassword.isNotEmpty
                            ? const Icon(Icons.close, color: Colors.red)
                            : null,
                  ),
                  obscureText: !isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

// Password Strength Indicator
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
                                    : const Color(0xFF009689),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

// Password Strength Text
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
                                  : const Color(0xFF009689),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    _signUpUser();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF009689),
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
                            return const BLoginScreen();
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
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+\s*$');
    return emailRegex.hasMatch(email);
  }

  PasswordStrength calculatePasswordStrength(String value) {
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasSymbols = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));

    int score = 0;

    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasSymbols) score++;
    if (hasDigits) score++;

    if (value.length < 6) return PasswordStrength.weak;
    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.medium;

    return PasswordStrength.weak;
  }

  _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      if (password == confirmPassword) {
        setState(() => isLoading = true);

        String result = await _authController.signUpUsers(
            email, fullName, phoneNumber, password, isSeller);

        setState(() => isLoading = false);

        if (result == 'Success') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful')));
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const MainScreen()));
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registration failed: $result')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')));
      }
    }
  }
}

enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}
