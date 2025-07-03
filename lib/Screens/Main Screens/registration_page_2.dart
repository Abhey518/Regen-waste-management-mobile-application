import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sign_in_page.dart';

class RegistrationScreen2 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String idNumber;
  final String phone;
  final String address;
  final String province;
  final String district;
  final String council;

  const RegistrationScreen2({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.idNumber,
    required this.phone,
    required this.address,
    required this.province,
    required this.district,
    required this.council,
  });

  @override
  State<RegistrationScreen2> createState() => _RegistrationScreen2State();
}

class _RegistrationScreen2State extends State<RegistrationScreen2> {
  bool _acceptAgreement = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  final SupabaseClient _supabase = Supabase.instance.client;

  get userId => null;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmPasswordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptAgreement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // 1. First create the auth user
      final authResponse = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw Exception('Registration failed - no user returned');
      }

      // 2. Get the session to ensure auth state is updated
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No session after sign up');
      }
      // 3. Insert user profile data with the same ID
      // ignore: unused_local_variable
      final response = await _supabase.from('users').insert({
        'id': userId,
        'email': _emailController.text.trim(),
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'phone': widget.phone,
        'nic_or_passport': widget.idNumber,
        'address': widget.address,
        'province_id': int.tryParse(widget.province) ?? 0,
        'district_id': int.tryParse(widget.district) ?? 0,
        'local_authority_id': int.tryParse(widget.council) ?? 0,
      }).select();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registration successful! Please check your email to verify your account.'),
            duration: Duration(seconds: 5),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
          (Route<dynamic> route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );

        // Attempt to delete the auth user if profile creation failed
        try {
          await _supabase.auth.admin.deleteUser(_emailController.text.trim());
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required FocusNode focusNode,
    required IconData icon,
    bool isPasswordField = false,
    VoidCallback? onSuffixPressed,
  }) {
    const primaryColor = Color(0xFF86c13c);
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(
        color: focusNode.hasFocus ? primaryColor : Colors.grey[600],
      ),
      prefixIcon: Icon(
        icon,
        color: focusNode.hasFocus ? primaryColor : Colors.grey,
      ),
      suffixIcon: isPasswordField
          ? IconButton(
              icon: Icon(
                onSuffixPressed != null
                    ? (_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility)
                    : (_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                color: focusNode.hasFocus ? primaryColor : Colors.grey,
              ),
              onPressed: onSuffixPressed ??
                  () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
            )
          : null,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(value)) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF86c13c);
    const fieldSpacing = 20.0;
    const horizontalPadding = 24.0;
    const verticalPadding = 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration - Step 2/2'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          labelText: 'Email Address',
                          focusNode: _emailFocusNode,
                          icon: Icons.email_outlined,
                        ),
                        validator: _validateEmail,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: fieldSpacing),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          labelText: 'Password',
                          focusNode: _passwordFocusNode,
                          icon: Icons.lock_outline,
                          isPasswordField: true,
                          onSuffixPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        validator: _validatePassword,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: fieldSpacing),
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        decoration: _buildInputDecoration(
                          labelText: 'Confirm Password',
                          focusNode: _confirmPasswordFocusNode,
                          icon: Icons.lock_outline,
                          isPasswordField: true,
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 12),
                      // Password Note
                      const Text(
                        'Password should be at least 8 characters with a mix of letters and numbers',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 17, 125, 2),
                        ),
                      ),
                      const SizedBox(height: fieldSpacing),
                      // Terms Agreement
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptAgreement,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptAgreement = value ?? false;
                              });
                            },
                            activeColor: primaryColor,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Terms and Conditions'),
                                    content: const SingleChildScrollView(
                                      child: Text(
                                        'Lorem ipsum dolor sit amet...', // Replace with actual terms
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                'I agree to the Terms and Conditions and Privacy Policy',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Register Button
            Container(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                verticalPadding + 8,
              ),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Complete Registration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
