import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sign_i_n_page/sign_i_n_page_widget.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String vin;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.vin,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _passwordUpdated = false;
  String? _errorMessage;
  bool _showAdvancedDebug = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _inspectDatabase() async {
    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .where('vin', isEqualTo: widget.vin)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userData = userQuery.docs.first.data();
        debugPrint('User document: ${userQuery.docs.first.id}');
        debugPrint('User data: $userData');
        debugPrint('Password field type: ${userData['password']?.runtimeType}');
      } else {
        debugPrint('No user found with email: ${widget.email} and VIN: ${widget.vin}');
      }
    } catch (e) {
      debugPrint('Firestore inspection failed: $e');
    }
  }

  Future<bool> _verifyOldPassword() async {
    try {
      if (_showAdvancedDebug) {
        await _inspectDatabase();
      }

      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .where('vin', isEqualTo: widget.vin)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        debugPrint('User not found');
        return false;
      }

      final storedPassword = userQuery.docs.first['password']?.toString() ?? '';
      final enteredPassword = _oldPasswordController.text;

      debugPrint('''
      ===== PASSWORD VERIFICATION =====
      Stored:  "$storedPassword" (${storedPassword.length} chars)
      Entered: "$enteredPassword" (${enteredPassword.length} chars)
      Exact Match: ${storedPassword == enteredPassword}
      Trimmed Match: ${storedPassword.trim() == enteredPassword.trim()}
      ''');

      return storedPassword == enteredPassword ||
          storedPassword.trim() == enteredPassword.trim();
    } catch (e) {
      debugPrint('Password verification error: $e');
      return false;
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'New passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isOldPasswordCorrect = await _verifyOldPassword();
      if (!isOldPasswordCorrect) {
        setState(() => _errorMessage = 'Incorrect old password');
        return;
      }

      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .where('vin', isEqualTo: widget.vin)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() => _errorMessage = 'User not found');
        return;
      }

      await userQuery.docs.first.reference.update({
        'password': _newPasswordController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => _passwordUpdated = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.pushNamed(SignINPageWidget.routeName);
      }
    } catch (e) {
      setState(() => _errorMessage = 'System error: ${e.toString()}');
      debugPrint('Password update error: $e');
    } finally {
      if (mounted && !_passwordUpdated) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_passwordUpdated) {
      return _buildSuccessScreen();
    }
    return _buildResetForm();
  }

  Widget _buildResetForm() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E7C37),
        title: Text(
          'Reset Password',
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              setState(() => _showAdvancedDebug = !_showAdvancedDebug);
              _inspectDatabase();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.lock_reset,
                size: 100,
                color: const Color(0xFF3E7C37),
              ),
              const SizedBox(height: 32),
              Text(
                'Reset Your Password',
                style: GoogleFonts.interTight(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your old password and set a new one',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Old Password Field
              _buildPasswordField(
                controller: _oldPasswordController,
                hintText: 'Old Password',
                isVisible: _oldPasswordVisible,
                onVisibilityChanged: () => setState(() => _oldPasswordVisible = !_oldPasswordVisible),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password Field
              _buildPasswordField(
                controller: _newPasswordController,
                hintText: 'New Password',
                isVisible: _newPasswordVisible,
                onVisibilityChanged: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 7) {
                    return 'Password must be at least 7 characters';
                  }
                  if (value == _oldPasswordController.text) {
                    return 'New password must be different';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              _buildPasswordField(
                controller: _confirmPasswordController,
                hintText: 'Confirm New Password',
                isVisible: _confirmPasswordVisible,
                onVisibilityChanged: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (_showAdvancedDebug) ...[
                const SizedBox(height: 16),
                Text(
                  'Debug mode active',
                  style: GoogleFonts.inter(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 40),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCB6432),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: const Color(0xFF6B6B6B)),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: onVisibilityChanged,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updatePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3E7C37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          'Update Password',
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: const Color(0xFF3E7C37),
              ),
              const SizedBox(height: 32),
              Text(
                'Password Updated!',
                style: GoogleFonts.interTight(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF262626),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your password has been successfully updated.',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed(SignINPageWidget.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E7C37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back to Login',
                    style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}