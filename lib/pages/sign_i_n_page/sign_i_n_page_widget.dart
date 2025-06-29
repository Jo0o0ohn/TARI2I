import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:john/index.dart';
import 'package:john/pages/AdmindashboardPage/admindashboard_page_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/services.dart';

class SignINPageWidget extends StatefulWidget {
  const SignINPageWidget({super.key});
  static String routeName = 'SignINPage';
  static String routePath = '/signINPage';

  @override
  State<SignINPageWidget> createState() => _SignINPageWidgetState();
}

class _SignINPageWidgetState extends State<SignINPageWidget> with WidgetsBindingObserver {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  bool _isLoading = false;
  bool _passwordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final user = _auth.currentUser;
    if (user != null && mounted) {
      _verifyAndRedirect(user.uid);
    }
  }

  Future<void> _verifyAndRedirect(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists && mounted) {
        final isAdmin = userDoc.data()?['isAdmin'] ?? false;
        if (isAdmin) {
          context.pushReplacementNamed(AdmindashboardPageWidget.routeName);
        } else {
          context.pushReplacementNamed(LoadingPageWidget.routeName);
        }
      }
    } catch (e) {
      debugPrint('Error verifying existing session: $e');
    }
  }

  @override
  void dispose() {
    _vinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
      return false;
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _showSnackbar('No internet access. Please check your connection.');
      return;
    }

    setState(() => _isLoading = true);

    final vin = _vinController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Direct authentication without AuthService
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        _showSnackbar('Sign in failed. Please try again.');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showSnackbar('User data not found in database.');
        await _auth.signOut();
        return;
      }

      final userData = userDoc.data()!;

      if (userData['vin'] != vin) {
        _showSnackbar('VIN number does not match.');
        await _auth.signOut();
        return;
      }

      if (!mounted) return;

      final isAdmin = userData['isAdmin'] ?? false;
      if (isAdmin) {
        context.pushReplacementNamed(AdmindashboardPageWidget.routeName);
      } else {
        context.pushReplacementNamed(LoadingPageWidget.routeName);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Invalid password.';
      } else if (e.code == 'network-request-failed' || e.code == 'timeout') {
        errorMessage = 'No internet access. Please check your connection.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many attempts. Try again later.';
      } else {
        errorMessage = 'Invalid email or password. Please try again.';
      }
      _showSnackbar(errorMessage);
    } catch (e) {
      _showSnackbar('An unexpected error occurred. Please try again.');
      debugPrint('Sign in error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must log in to continue.')),
          );
        }
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.0,
                    height: 93.39,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                  ),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'assets/images/Blue_Gold_Minimalist_Car_Showroom_Logo.png',
                      width: 300,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // VIN Input Field
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: _vinController,
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'Chassis/VIN Number',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.directions_car,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 20.0,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your VIN number';
                                }
                                if (value.length < 17) {
                                  return 'VIN must be 17 characters';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9]')),
                                LengthLimitingTextInputFormatter(17),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Input Field
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 20.0,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Input Field
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  letterSpacing: 0.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 20.0,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                  child: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              if (mounted) context.pushNamed('ForgotpasswordPage');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                ),
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sign In Button
                        _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        )
                            : FFButtonWidget(
                          onPressed: _signIn,
                          text: 'Sign In',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50.0,
                            padding: const EdgeInsets.all(8.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                              font: GoogleFonts.interTight(
                                fontWeight: FontWeight.w600,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.normal,
                                ),
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (mounted) context.pushNamed('SignupPage');
                              },
                              child: Text(
                                ' Sign Up',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '© 2023 Tari2i. All rights reserved.',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.normal,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}