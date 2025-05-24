import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:john/my_database.dart';

import '../../flutter_flow/flutter_flow_theme.dart';


class SignupPageWidget extends StatefulWidget {
  const SignupPageWidget({super.key});

  // Add these static route properties
  static const String routeName = 'SignupPage';
  static const String routePath = '/signup';

  @override
  State<SignupPageWidget> createState() => _SignupPageWidgetState();
}
class _SignupPageWidgetState extends State<SignupPageWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vinController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  final _databaseHelper = AppDatabase();

  // Updated Color Scheme as requested
  final Color primaryColor = const Color(0xFF3E7C37); // Green
  final Color accentColor = const Color(0xFFCB6432);  // Orange
  final Color backgroundColor = const Color(0xFFFFFFFF); // White
  final Color textColor = const Color(0xFF262626); // Gray (fixed opacity)
  final Color buttonTextColor = const Color(0xFF6B6B6B); // Dark Gray
  final Color secondary = const Color(0xFFF3F3F3); // buttpn


  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _vinController.dispose();
    _databaseHelper.close();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Check for existing email
      final email = _emailController.text.trim();
      if (await _databaseHelper.checkEmailExists(email)) {
        throw 'Email already registered';
      }

      // 2. Check for existing VIN
      final vin = _vinController.text.trim();
      if (await _databaseHelper.checkVinExists(vin)) {
        throw 'VIN already registered';
      }

      // 3. Prepare user data (hash password in production!)
      final user = {
        'fullName': _fullNameController.text.trim(),
        'email': email,
        'password': _passwordController.text,
        'vin': vin,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 4. Insert with transaction
      final db = await _databaseHelper.database;
      await db.transaction((txn) async {
        try {
          final id = await txn.insert('Users', user);
          if (id == 0) throw Exception('Insert failed');

          // Add any additional related operations here
        } catch (e) {
          debugPrint('Transaction error: $e');
          rethrow;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Registration successful!', false),
      );
      _formKey.currentState?.reset();

    } on DatabaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(_parseDatabaseError(e), true),
      );
      debugPrint('Database error: ${e.toString()}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(e.toString(), true),
      );
      debugPrint('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
//checking db
  String _parseDatabaseError(DatabaseException e) {
    if (e.isUniqueConstraintError()) return 'Email or VIN already exists';
    if (e.toString().contains('no such table')) return 'Database not initialized';
    if (e.toString().contains('column')) return 'Database schema mismatch';
    return 'Database operation failed. Please try again.';
  }
  SnackBar _buildSnackBar(String message, bool isError) {
    return SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.red[800] : primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(
          color: backgroundColor,
          fontWeight: FontWeight.bold,
        )),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: backgroundColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/Blue_Gold_Minimalist_Car_Showroom_Logo.png',
                width: 450,
                height: 400,
                fit: BoxFit.cover
              ),
              const SizedBox(height: 32),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _vinController,
                label: 'VIN (17 characters)',
                icon: Icons.confirmation_num_outlined,
                validator: (v) => v!.length != 17 ? 'Must be 17 characters' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: primaryColor),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      )
    );
  }
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(color: textColor),
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: accentColor,
          ),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
        filled: true,
        fillColor:secondary,// Add your desired background color here
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withOpacity(0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}