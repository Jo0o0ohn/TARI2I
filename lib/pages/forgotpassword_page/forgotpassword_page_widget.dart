import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:john/my_database.dart';
import '../Reset_password/reset_password_widget.dart';

class ForgotpasswordPageWidget extends StatefulWidget {
  const ForgotpasswordPageWidget({super.key});

  static String routeName = 'ForgotpasswordPage';
  static String routePath = '/ForgotpasswordPage';

  @override
  State<ForgotpasswordPageWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotpasswordPageWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _vinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _verifyUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordPage(
          email: _emailController.text.trim(),
          vin: _vinController.text.trim(),
        ),
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E7C37),
        title: Text(
          'Forgot Password',
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
              const SizedBox(height: 24),
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
                'Enter your email and VIN to verify your identity',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B6B6B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildVinField(),
              const SizedBox(height: 32),
              _buildContinueButton(),
              const SizedBox(height: 20),
              _buildRememberPassword(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
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
        controller: _emailController,
        decoration: InputDecoration(
          hintText: 'Email Address',
          hintStyle: GoogleFonts.inter(color: const Color(0xFF6B6B6B)),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.email, size: 20),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildVinField() {
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
        controller: _vinController,
        decoration: InputDecoration(
          hintText: 'Vehicle VIN',
          hintStyle: GoogleFonts.inter(color: const Color(0xFF6B6B6B)),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.directions_car, size: 20),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3E7C37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          'Continue',
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberPassword() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        'Remember your password? Sign In',
        style: GoogleFonts.inter(
          color: const Color(0xFF3E7C37),
        ),
      ),
    );
  }
}
