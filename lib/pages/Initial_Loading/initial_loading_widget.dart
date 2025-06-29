import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/index.dart';
import '/pages/AdmindashboardPage/admindashboard_page_widget.dart';
// import '/pages/Sign_i_n_page/sign_i_n_page_widget.dart' ;

class InitialLoadingPageWidget extends StatefulWidget {
  const InitialLoadingPageWidget({super.key});

  static String routeName = 'InitialLoadingPage';
  static String routePath = '/initialLoadingPage';

  @override
  State<InitialLoadingPageWidget> createState() => _InitialLoadingPageWidgetState();
}

class _InitialLoadingPageWidgetState extends State<InitialLoadingPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    await Future.delayed(const Duration(seconds: 1)); // Initial delay for smooth transition

    try {
      final user = _auth.currentUser;

      if (user == null) {
        // No valid token - redirect to login
        if (mounted) {
          context.pushReplacementNamed(SignINPageWidget.routeName);
        }
        return;
      }

      // Token exists - verify user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // User document doesn't exist - redirect to login
        await _auth.signOut();
        if (mounted) {
          context.pushReplacementNamed(SignINPageWidget.routeName);
        }
        return;
      }

      // Check user role and redirect accordingly
      final isAdmin = userDoc.data()?['isAdmin'] ?? false;
      if (mounted) {
        context.pushReplacementNamed(
            isAdmin
                ? AdmindashboardPageWidget.routeName
                : MainmenuPageWidget.routeName
        );
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      if (mounted) {
        context.pushReplacementNamed(SignINPageWidget.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF1A1A1A),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondary,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/Blue_Gold_Minimalist_Car_Showroom_Logo.png',
                    width: 342.2,
                    height: 221.54,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: Text(
                    'Checking authentication...',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.normal,
                      ),
                      color: const Color(0xFFCCCCCC),
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                  child: Container(
                    width: 200.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FlutterFlowTheme.of(context).alternate,
                          const Color(0xFFFFAB91)
                        ],
                        stops: const [0.0, 1.0],
                        begin: const AlignmentDirectional(1.0, 0.0),
                        end: const AlignmentDirectional(-1.0, 0),
                      ),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 0.0),
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: CircularPercentIndicator(
                      percent: 0.75,
                      radius: 25.0,
                      lineWidth: 50.0,
                      animation: true,
                      animateFromLastPercent: true,
                      progressColor: FlutterFlowTheme.of(context).secondary,
                      backgroundColor: const Color(0x33FFFFFF),
                    ),
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