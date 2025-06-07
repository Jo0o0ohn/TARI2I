import 'package:cloud_firestore/cloud_firestore.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admindashboard_page_model.dart';
export 'admindashboard_page_model.dart';

class AdmindashboardPageWidget extends StatefulWidget {
  const AdmindashboardPageWidget({super.key});

  static String routeName = 'AdmindashboardPage';
  static String routePath = '/admindashboardPage';

  @override
  State<AdmindashboardPageWidget> createState() =>
      _AdmindashboardPageWidgetState();
}

class _AdmindashboardPageWidgetState extends State<AdmindashboardPageWidget> {
  late AdmindashboardPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdmindashboardPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Admin Dashboard',
            style: FlutterFlowTheme.of(context).headlineLarge.override(
              font: GoogleFonts.interTight(
                fontWeight: FontWeight.bold,
                fontStyle:
                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).primaryBackground,
              fontSize: 24,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
              fontStyle:
              FlutterFlowTheme.of(context).headlineLarge.fontStyle,
            ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [

                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x1A000000),
                            offset: Offset(
                              0.0,
                              2,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Alerts',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                            ),
                            SizedBox(height: 12),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('alerts').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error loading alerts');
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                final alertDocs = snapshot.data?.docs ?? [];

                                if (alertDocs.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text('No active alerts', style: TextStyle(fontSize: 16)),
                                  );
                                }

                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: alertDocs.length,
                                  itemBuilder: (context, index) {
                                    final alertData = alertDocs[index].data()! as Map<String, dynamic>;
                                    final alertId = alertDocs[index].id;

                                    final title = alertData['title'] ?? 'User Alert';
                                    final message = alertData['message'] ?? 'No message provided';
                                    final sentBy = alertData['sentBy'] ?? 'Unknown';  // Who sent alert

                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF8D7DA),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.warning_rounded, color: Color(0xFF721C24), size: 24),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      title,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF721C24),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      message,
                                                      style: TextStyle(
                                                        color: Color(0xFF721C24).withOpacity(0.8),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      'Sent by: $sentBy',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontStyle: FontStyle.italic,
                                                        color: Color(0xFF721C24).withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete, color: Color(0xFF721C24)),
                                                onPressed: () async {
                                                  final confirmed = await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text('Delete Alert'),
                                                      content: Text('Are you sure you want to delete this alert?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(false),
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () => Navigator.of(context).pop(true),
                                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirmed == true) {
                                                    await FirebaseFirestore.instance
                                                        .collection('alerts')
                                                        .doc(alertId)
                                                        .delete();
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Alert deleted')),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x1A000000),
                            offset: Offset(
                              0.0,
                              2,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Users',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                ),
                                Container(
                                  width: 200,
                                  child: TextFormField(
                                    controller: _model.textController1,
                                    focusNode: _model.textFieldFocusNode1,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Search users...',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontWeight,
                                          fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0x00000000),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 20,
                                      ),
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      font: GoogleFonts.inter(
                                        fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    validator: _model.textController1Validator
                                        .asValidator(context),
                                  ),
                                ),
                              ],
                            ),
                            ListView(
                              padding: EdgeInsets.zero,
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      'Sarah Johnson',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'sarah.j@example.com • Last active: Today',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontWeight,
                                          fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.delete_outline,
                                      color: FlutterFlowTheme.of(context).error,
                                      size: 20,
                                    ),
                                    dense: false,
                                    contentPadding:
                                    EdgeInsetsDirectional.fromSTEB(
                                        12, 8, 12, 8),
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: FlutterFlowTheme.of(context).alternate,
                                ),

                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      'David Rodriguez',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'drodriguez@example.com • Last active: 1 week ago',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontWeight,
                                          fontStyle:
                                          FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.delete_outline,
                                      color: FlutterFlowTheme.of(context).error,
                                      size: 20,
                                    ),
                                    dense: false,
                                    contentPadding:
                                    EdgeInsetsDirectional.fromSTEB(
                                        12, 8, 12, 8),
                                  ),
                                ),
                              ],
                            ),
                          ].divide(SizedBox(height: 16)),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color(0x1A000000),
                            offset: Offset(
                              0.0,
                              2,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Remove User',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.textController2,
                                focusNode: _model.textFieldFocusNode2,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'User Email or ID',
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                      FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                                  hintText: 'Enter user email or ID',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                      FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                validator: _model.textController2Validator
                                    .asValidator(context),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'This action cannot be undone',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                      FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                                ),
                                FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: 'Remove User',
                                  options: FFButtonOptions(
                                    height: 36,
                                    padding: EdgeInsets.all(8),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, 0),
                                    color: FlutterFlowTheme.of(context).error,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                      font: GoogleFonts.inter(
                                        fontWeight:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle:
                                        FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                      fontWeight:
                                      FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle:
                                      FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ].divide(SizedBox(height: 12)),
                        ),
                      ),
                    ),
                  ),
                ].divide(SizedBox(height: 16)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}