import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../sign_i_n_page/sign_i_n_page_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admindashboard_page_model.dart';
export 'admindashboard_page_model.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';



class AdmindashboardPageWidget extends StatefulWidget {
  const AdmindashboardPageWidget({super.key});

  static const String routeName = 'AdmindashboardPage';
  static const String routePath = '/admin';

  @override
  State<AdmindashboardPageWidget> createState() =>
      _AdmindashboardPageWidgetState();
}

class _AdmindashboardPageWidgetState extends State<AdmindashboardPageWidget> {
  late AdmindashboardPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  BluetoothConnection? _connection;
  String _bluetoothMessage = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdmindashboardPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    requestPermissions().then((_) => _connectToBluetooth());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
    _connection?.dispose();
    _connection = null;
  }
  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  void _connectToBluetooth() async {
    try {
      BluetoothDevice? hc06;
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();

      for (var d in devices) {
        if (d.name == 'HC-06') {
          hc06 = d;
          break;
        }
      }

      if (hc06 == null) {
        print('HC-06 not paired');
        return;
      }

      _connection = await BluetoothConnection.toAddress(hc06.address);
      print('Connected to HC-06');

      _connection!.input!.listen((data) {
        final msg = String.fromCharCodes(data).trim();
        print('Received: $msg');

        if (msg.contains("c") || msg.contains("o")) { // C for Crash, O for Obstacle
          _addCarAlertToFirestore(msg); // Call a function that shows the alert
        }
      }).onDone(() {
        print('Bluetooth disconnected');
      });

    } catch (e) {
      print('Bluetooth Error: $e');
    }
  }
  Future<void> _addCarAlertToFirestore(String message) async {
    final alert = {
      'title': 'Car Alert',
      'message': message,
      'sentBy': 'Car System',
      'email': 'N/A',
      'location': {
        'latitude': 0.0,
        'longitude': 0.0,
      },
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('alerts').add(alert);
    print('✅ Car alert added to Firestore');
  }

  Future<void> _showLogoutConfirmationDialog() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: FlutterFlowTheme
                .of(context)
                .headlineSmall
                .override(
              fontFamily: 'Inter Tight',
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme
                  .of(context)
                  .primaryText,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: FlutterFlowTheme
                .of(context)
                .bodyMedium
                .override(
              fontFamily: 'Inter',
              color: FlutterFlowTheme
                  .of(context)
                  .secondaryText,
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
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme
                      .of(context)
                      .secondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              child: Text(
                'Log Out',
                style: FlutterFlowTheme
                    .of(context)
                    .bodyMedium
                    .override(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme
                      .of(context)
                      .primary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      context.pushNamed(SignINPageWidget.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Exit the app when back is pressed on main menu
      SystemNavigator.pop();
      return false;
    },
    child: GestureDetector(
    onTap: () {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    },
    behavior: HitTestBehavior.opaque,
    child: Scaffold(
    key: scaffoldKey,
    backgroundColor: FlutterFlowTheme
        .of(context)
        .primaryBackground,
    appBar: AppBar(
    backgroundColor: FlutterFlowTheme
        .of(context)
        .primaryBackground,
    automaticallyImplyLeading: false,
    leading: FlutterFlowIconButton(
    borderColor: Colors.transparent,
    borderRadius: 30,
    borderWidth: 1,
    buttonSize: 60,
    icon: Icon(
    Icons.arrow_back_rounded,
    color: FlutterFlowTheme
        .of(context)
        .primaryText,
    size: 30,
    ),
    onPressed: () async {
    await _showLogoutConfirmationDialog();
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
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 25,
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
                                    final sentBy = alertData['sentBy'] ?? 'Unknown';
                                    final email = alertData['email'] ?? 'No email';
                                    final location = alertData['location'] ?? {};
                                    final latitude = location['latitude']?.toStringAsFixed(4) ?? 'N/A';
                                    final longitude = location['longitude']?.toStringAsFixed(4) ?? 'N/A';
                                    final timestamp = (alertData['timestamp'] as Timestamp?)?.toDate();
                                    final formattedTime = timestamp != null
                                        ? '${timestamp.toLocal()}'.split('.')[0] // Trim microseconds
                                        : 'No time';
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
                                                    SizedBox(height: 2),
                                                    Text(
                                                      'Email: $email',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontStyle: FontStyle.italic,
                                                        color: Color(0xFF721C24).withOpacity(0.6),
                                                      ),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      'Location: Lat $latitude, Long $longitude',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontStyle: FontStyle.italic,
                                                        color: Color(0xFF721C24).withOpacity(0.6),
                                                      ),
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      'Time: $formattedTime',
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
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value.toLowerCase().trim();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Search users...',
                                      hintStyle: FlutterFlowTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                          FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                          fontStyle:
                                          FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight:
                                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                        fontStyle:
                                        FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context).alternate,
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
                                      fillColor: FlutterFlowTheme.of(context).primaryBackground,
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20,
                                      ),
                                    ),
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(
                                        fontWeight:
                                        FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle:
                                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    validator: _model.textController1Validator.asValidator(context),
                                  ),
                                ),

                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').where('isAdmin', isEqualTo:false).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error loading users');
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                final userDocs = snapshot.data?.docs ?? [];

                                if (userDocs.isEmpty) {
                                  return Text('No users found');
                                }
                                final filteredUsers = userDocs.where((user) {
                                  final fullname = user['fullname'].toString().toLowerCase();
                                  return fullname.contains(_searchQuery);
                                }).toList();

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                  itemCount: filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final userData = filteredUsers[index].data() as Map<String, dynamic>;
                                    final name = userData['fullname'] ?? 'Unknown';
                                    final email = userData['email'] ?? 'No email';
                                    final lastActive = userData['lastActive'] ?? 'N/A';

                                    return Material(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        title: Text(
                                          name,
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                        ),
                                        subtitle: Text(
                                          email,
                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                              fontStyle:
                                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                            FlutterFlowTheme.of(context).bodySmall.fontWeight,
                                            fontStyle:
                                            FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete, color: Color(0xFF8B0000)),
                                          onPressed: () async {
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Delete User'),
                                                content: Text('Are you sure you want to delete this user?'),
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
                                              try {
                                                final userId = userDocs[index].id;
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(userId) // 🔁 Make sure you have this!
                                                    .delete();

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('User deleted')),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Failed to delete user: $e')),
                                                );
                                              }
                                            }
                                          },
                                        ),

                                        dense: false,
                                        contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),

                          ].divide(SizedBox(height: 16)),
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
      ),
    );
  }
}