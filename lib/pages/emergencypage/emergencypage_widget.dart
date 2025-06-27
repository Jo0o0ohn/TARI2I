import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../../my_database.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'emergencypage_model.dart';
export 'emergencypage_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class EmergencypageWidget extends StatefulWidget {
  const EmergencypageWidget({super.key});

  static String routeName = 'Emergencypage';
  static String routePath = '/emergencypage';

  @override
  State<EmergencypageWidget> createState() => _EmergencypageWidgetState();
}

class _EmergencypageWidgetState extends State<EmergencypageWidget> {
  late EmergencypageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmergencypageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _showConfirmationDialog() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: Text(
            'Confirm Alert',
            style: FlutterFlowTheme
                .of(context)
                .headlineSmall
                .override(
              font: GoogleFonts.interTight(
                fontWeight:
                FlutterFlowTheme
                    .of(context)
                    .headlineSmall
                    .fontWeight,
                fontStyle:
                FlutterFlowTheme
                    .of(context)
                    .headlineSmall
                    .fontStyle,
              ),
              color: FlutterFlowTheme
                  .of(context)
                  .primaryText,
              letterSpacing: 0.0,
            ),
          ),
          content: Text(
            'Are you sure you want to alert emergency services and police?',
            style: FlutterFlowTheme
                .of(context)
                .bodyMedium
                .override(
              font: GoogleFonts.inter(
                fontWeight:
                FlutterFlowTheme
                    .of(context)
                    .bodyMedium
                    .fontWeight,
                fontStyle:
                FlutterFlowTheme
                    .of(context)
                    .bodyMedium
                    .fontStyle,
              ),
              color: FlutterFlowTheme
                  .of(context)
                  .secondaryText,
              letterSpacing: 0.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, false),
              child: Text(
                'Cancel',
                style: FlutterFlowTheme
                    .of(context)
                    .bodyMedium
                    .override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                    FlutterFlowTheme
                        .of(context)
                        .bodyMedium
                        .fontStyle,
                  ),
                  color: FlutterFlowTheme
                      .of(context)
                      .secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              child: Text(
                'Yes, Alert',
                style: FlutterFlowTheme
                    .of(context)
                    .bodyMedium
                    .override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                    FlutterFlowTheme
                        .of(context)
                        .bodyMedium
                        .fontStyle,
                  ),
                  color: FlutterFlowTheme
                      .of(context)
                      .primary,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw 'User not signed in';

        final uid = user.uid;
        final email = user.email ?? 'unknown';

        // 🔹 1. Get user's Firestore data (like name)
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (!userDoc.exists) throw 'User document not found in Firestore';

        final userData = userDoc.data()!;
        final senderName = userData['fullname'] ?? 'Unknown User';

        // 🔹 2. Get location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final location = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };

        // 🔹 3. Check if alert already sent
        final existingAlert = await FirebaseFirestore.instance
            .collection('alerts')
            .where('sentBy', isEqualTo: senderName)
            .limit(1)
            .get();

        if (existingAlert.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('You have already sent an emergency alert.')),
          );
          return;
        }

        // 🔹 4. Prepare and send alert
        final alertData = {
          'timestamp': FieldValue.serverTimestamp(),
          'message': 'Emergency alert triggered',
          'status': 'new',
          'sentBy': senderName,
          'email': email,
          'name': senderName,
          'location': location,
        };

        await FirebaseFirestore.instance.collection('alerts').add(alertData);

        await _showSuccessDialog();
      } catch (e) {
        print('Failed to send alert: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send alert. Please try again.')),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: Text(
            'Alert Sent Successfully',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              font: GoogleFonts.interTight(
                fontWeight:
                FlutterFlowTheme.of(context).headlineSmall.fontWeight,
                fontStyle:
                FlutterFlowTheme.of(context).headlineSmall.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
            ),
          ),
          content: Text(
            'Emergency services have been alerted. Please follow any further instructions and stay safe.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(
                fontWeight:
                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle:
                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: Text(
                'OK',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                    FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primary,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: FlutterFlowIconButton(
          borderRadius: 20,
          buttonSize: 40,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Emergency',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Warning Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 64,
                ),
              ),
              SizedBox(height: 24),

              // Title
              Text(
                'Emergency Alert',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'If you\'re in immediate danger, tap the button below to contact emergency services and police.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Emergency Button
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showConfirmationDialog,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_police_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Contact Emergency Services',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Location Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Your location will be shared with emergency services when you make the call.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stay on the line until help arrives.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Cancel Button
              FFButtonWidget(
                onPressed: () => Navigator.of(context).pop(),
                text: 'Cancel',
                options: FFButtonOptions(
                  width: 200,
                  height: 50,
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  textStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  elevation: 0,
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}