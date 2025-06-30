import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../sign_i_n_page/sign_i_n_page_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'admindashboard_page_model.dart';
export 'admindashboard_page_model.dart';

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

  // Bluetooth status variables
  bool _isBluetoothConnected = false;
  bool _isBluetoothConnecting = false;
  String _bluetoothStatus = 'Disconnected';
  bool _bluetoothEnabled = false;
  StreamSubscription<Uint8List>? _btSubscription;
  bool _alertSent = false;
  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdmindashboardPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _checkBluetoothState();
    requestPermissions().then((_) => _connectToBluetooth());
  }

  Future<void> _checkBluetoothState() async {
    bool? enabled = await FlutterBluetoothSerial.instance.isEnabled;
    setState(() {
      _bluetoothEnabled = enabled ?? false;
      if (!_bluetoothEnabled) {
        _bluetoothStatus = 'Bluetooth is disabled';
      }
    });
  }

  @override
  void dispose() {
    _btSubscription?.cancel();
    _btSubscription = null;
    _connection?.dispose();
    _connection = null;
    _model.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  void _connectToBluetooth() async {
    if (!_bluetoothEnabled) {
      setState(() {
        _bluetoothStatus = 'Bluetooth is disabled';
      });
      return;
    }

    const hc06Address = '00:22:06:01:CE:5A';
    print('🔌 Attempting to connect to HC-06 at $hc06Address');

    try {
      setState(() {
        _isBluetoothConnecting = true;
        _bluetoothStatus = 'Connecting to HC-06...';
      });

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
        setState(() {
          _isBluetoothConnecting = false;
          _isBluetoothConnected = false;
          _bluetoothStatus = 'HC-06 not found';
        });
        return;
      }

      _connection = await BluetoothConnection.toAddress(hc06Address);
      print('Connected to HC-06');

      setState(() {
        _isBluetoothConnecting = false;
        _isBluetoothConnected = true;
        _bluetoothStatus = 'Connected to HC-06';
      });

      _btSubscription = _connection!.input!.listen((data) async {
        final msg = String.fromCharCodes(data);
        final cleanedMsg = msg.trim().toLowerCase();

        print('📥 Raw received: $msg');
        print('🔍 Cleaned msg: $cleanedMsg');

        if (!_alertSent && cleanedMsg.contains('c')) {
          print('🚨 First "c" received. Sending alert.');
          _alertSent = true;
          await _addCarAlertToFirestore(cleanedMsg);

          await _btSubscription?.cancel();
          _btSubscription = null;

          setState(() {
            _bluetoothStatus = 'Alert sent. Bluetooth listening stopped.';
          });
        }
      },
          onDone: () {
            print('Bluetooth disconnected');
            setState(() {
              _isBluetoothConnected = false;
              _bluetoothStatus = 'Disconnected';
            });
          },
          onError: (error) {
            print('❌ Bluetooth stream error: $error');
            setState(() {
              _isBluetoothConnected = false;
              _bluetoothStatus = 'Connection error';
            });
          });

    } catch (e) {
      print('Bluetooth Error: $e');
      setState(() {
        _isBluetoothConnecting = false;
        _isBluetoothConnected = false;
        _bluetoothStatus = 'Connection failed';
      });
    }
  }  Future<void> _addCarAlertToFirestore(String message) async {
    try {
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
      print('✅ Car alert added to Firestore: $message');
    } catch (e) {
      print('❌ Failed to add alert to Firestore: $e');
    }
  }
  Future<void> _showLogoutConfirmationDialog() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              fontFamily: 'Inter Tight',
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Inter',
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, false),
              child: Text(
                'Cancel',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              child: Text(
                'Log Out',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primary,
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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30,
              borderWidth: 1,
              buttonSize: 60,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 30,
              ),
              onPressed: () async {
                await _showLogoutConfirmationDialog();
              },
            ),
            title: Text(
              'Admin Dashboard',
              style: FlutterFlowTheme.of(context).headlineLarge.override(
                fontFamily: 'Inter Tight',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                letterSpacing: 0.0,
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
                    // Bluetooth Status Indicator
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isBluetoothConnected
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isBluetoothConnected
                                ? Colors.green
                                : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isBluetoothConnected
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth_disabled,
                              color: _isBluetoothConnected
                                  ? Colors.green
                                  : Colors.red,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _bluetoothStatus,
                                style: TextStyle(
                                  color: _isBluetoothConnected
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_isBluetoothConnecting)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                                ),
                              ),
                            if (!_isBluetoothConnected &&
                                !_isBluetoothConnecting)
                              TextButton(
                                onPressed: _connectToBluetooth,
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: _bluetoothEnabled ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Active Alerts Section
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
                              offset: Offset(0.0, 2),
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
                                  fontFamily: 'Inter Tight',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('alerts')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error loading alerts');
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final alertDocs = snapshot.data?.docs ?? [];

                                  if (alertDocs.isEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text('No active alerts',
                                          style: TextStyle(fontSize: 16)),
                                    );
                                  }

                                  return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: alertDocs.length,
                                    itemBuilder: (context, index) {
                                      final alertData = alertDocs[index].data()!
                                      as Map<String, dynamic>;
                                      final alertId = alertDocs[index].id;

                                      final title =
                                          alertData['title'] ?? 'User Alert';
                                      final message = alertData['message'] ??
                                          'No message provided';
                                      final sentBy =
                                          alertData['sentBy'] ?? 'Unknown';
                                      final email =
                                          alertData['email'] ?? 'No email';
                                      final location =
                                          alertData['location'] ?? {};
                                      final latitude = location['latitude']
                                          ?.toStringAsFixed(4) ??
                                          'N/A';
                                      final longitude = location['longitude']
                                          ?.toStringAsFixed(4) ??
                                          'N/A';
                                      final timestamp =
                                      (alertData['timestamp'] as Timestamp?)
                                          ?.toDate();
                                      final formattedTime = timestamp != null
                                          ? '${timestamp.toLocal()}'
                                          .split('.')[0]
                                          : 'No time';
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF8D7DA),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.warning_rounded,
                                                    color: Color(0xFF721C24),
                                                    size: 24),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        title,
                                                        style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          color:
                                                          Color(0xFF721C24),
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        message,
                                                        style: TextStyle(
                                                          color: Color(0xFF721C24)
                                                              .withOpacity(0.8),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(height: 6),
                                                      Text(
                                                        'Sent by: $sentBy',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                          FontStyle.italic,
                                                          color: Color(0xFF721C24)
                                                              .withOpacity(0.6),
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        'Email: $email',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                          FontStyle.italic,
                                                          color: Color(0xFF721C24)
                                                              .withOpacity(0.6),
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        'Location: Lat $latitude, Long $longitude',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                          FontStyle.italic,
                                                          color: Color(0xFF721C24)
                                                              .withOpacity(0.6),
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        'Time: $formattedTime',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                          FontStyle.italic,
                                                          color: Color(0xFF721C24)
                                                              .withOpacity(0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete,
                                                      color: Color(0xFF721C24)),
                                                  onPressed: () async {
                                                    final confirmed =
                                                    await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title:
                                                            Text('Delete Alert'),
                                                            content: Text(
                                                                'Are you sure you want to delete this alert?'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop(false),
                                                                child: Text('Cancel'),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                        context)
                                                                        .pop(true),
                                                                child: Text('Delete',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red)),
                                                              ),
                                                            ],
                                                          ),
                                                    );

                                                    if (confirmed == true) {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('alerts')
                                                          .doc(alertId)
                                                          .delete();
                                                      ScaffoldMessenger.of(
                                                          context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                            content: Text(
                                                                'Alert deleted')),
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

                    // Users Section
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
                              offset: Offset(0.0, 2),
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
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Users',
                                    style: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .override(
                                      fontFamily: 'Inter Tight',
                                      fontWeight: FontWeight.w600,
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
                                          _searchQuery =
                                              value.toLowerCase().trim();
                                        });
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: 'Search users...',
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                          fontFamily: 'Inter',
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor:
                                        FlutterFlowTheme.of(context)
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
                                        fontFamily: 'Inter',
                                      ),
                                      validator: _model.textController1Validator
                                          .asValidator(context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('isAdmin', isEqualTo: false)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error loading users');
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final userDocs = snapshot.data?.docs ?? [];

                                  if (userDocs.isEmpty) {
                                    return Text('No users found');
                                  }
                                  final filteredUsers = userDocs.where((user) {
                                    final fullname = user['fullname']
                                        .toString()
                                        .toLowerCase();
                                    return fullname.contains(_searchQuery);
                                  }).toList();

                                  return ListView.separated(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    separatorBuilder: (_, __) => Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                    itemCount: filteredUsers.length,
                                    itemBuilder: (context, index) {
                                      final userData = filteredUsers[index]
                                          .data() as Map<String, dynamic>;
                                      final name =
                                          userData['fullname'] ?? 'Unknown';
                                      final email =
                                          userData['email'] ?? 'No email';
                                      final lastActive =
                                          userData['lastActive'] ?? 'N/A';

                                      return Material(
                                        color: Colors.transparent,
                                        child: ListTile(
                                          title: Text(
                                            name,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                            email,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Color(0xFF8B0000)),
                                            onPressed: () async {
                                              final confirmed =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: Text('Delete User'),
                                                      content: Text(
                                                          'Are you sure you want to delete this user?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(context)
                                                                  .pop(false),
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(context)
                                                                  .pop(true),
                                                          child: Text('Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red)),
                                                        ),
                                                      ],
                                                    ),
                                              );

                                              if (confirmed == true) {
                                                try {
                                                  final userId =
                                                      userDocs[index].id;
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(userId)
                                                      .delete();

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'User deleted')),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'Failed to delete user: $e')),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                          dense: false,
                                          contentPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              12, 8, 12, 8),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}