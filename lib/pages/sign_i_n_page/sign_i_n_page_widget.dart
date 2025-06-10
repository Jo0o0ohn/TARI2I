import 'package:cloud_firestore/cloud_firestore.dart';
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

class _SignINPageWidgetState extends State<SignINPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;


  @override
  void dispose() {
    _vinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final vin = _vinController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // 2. Fetch user doc from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _showSnackbar('User data not found in database.');
        await FirebaseAuth.instance.signOut();
        return;
      }

      final userData = userDoc.data()!;

      // 3. Check VIN matches
      if (userData['vin'] != vin) {
        _showSnackbar('VIN number does not match.');
        await FirebaseAuth.instance.signOut();
        return;
      }

      // 4. Check admin status
      final isAdmin = userData['isAdmin'] ?? false;
      if (!mounted) return; // early return if widget is unmounted

      if (isAdmin && mounted) {
        context.pushNamed(AdmindashboardPageWidget.routeName);
      }
      else {
        context.pushNamed(LoadingPageWidget.routeName);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showSnackbar('Incorrect password.');
      } else {
        _showSnackbar('Invalid email or password. Please try again.');
      }
    } catch (e) {
      _showSnackbar('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
                    alignment: const Alignment(0.0, 0.0),
                  ),
                ),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                          FlutterFlowTheme.of(context).secondaryBackground,
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
                            autofocus: false,
                            textCapitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.next,
                            obscureText: false,
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
                              errorStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.normal,
                                ),
                                color: FlutterFlowTheme.of(context).error,
                                letterSpacing: 0.0,
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.directions_car,
                                color:
                                FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                              ),
                              letterSpacing: 0.0,
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
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                          FlutterFlowTheme.of(context).secondaryBackground,
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
                            autofocus: false,
                            textCapitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.next,
                            obscureText: false,
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
                              errorStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.normal,
                                ),
                                color: FlutterFlowTheme.of(context).error,
                                letterSpacing: 0.0,
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color:
                                FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                              ),
                              letterSpacing: 0.0,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                          FlutterFlowTheme.of(context).secondaryBackground,
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
                            textCapitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.done,
                            obscureText: !_passwordVisible,
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
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color:
                                FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                focusNode: FocusNode(skipTraversal: true),
                                child: Icon(
                                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                              ),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                              ),
                              letterSpacing: 0.0,
                            ),
                            keyboardType: TextInputType.visiblePassword,
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
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              try {
                                if (context.mounted) {
                                  context.pushNamed(
                                      ForgotpasswordPageWidget.routeName);
                                }
                              } catch (e) {
                                debugPrint(
                                    'Navigation to SignUpPage failed: $e');
                              }
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
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600,
                            ),
                            color: FlutterFlowTheme.of(context)
                                .primaryBackground,
                            letterSpacing: 0.0,
                          ),
                          elevation: 2.0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ].divide(const SizedBox(height: 16.0)),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.normal,
                                ),
                                color: FlutterFlowTheme.of(context).primary,
                                letterSpacing: 0.0,
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                try {
                                  if (context.mounted) {
                                    context
                                        .pushNamed(SignupPageWidget.routeName);
                                  }
                                } catch (e) {
                                  debugPrint(
                                      'Navigation to SignUpPage failed: $e');
                                }
                              },
                              child: Text(
                                ' Sign Up',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondary,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '© 2023 Tari2i. All rights reserved.',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.normal,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
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
    );
  }
}