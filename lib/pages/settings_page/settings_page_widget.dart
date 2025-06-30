import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../sign_i_n_page/sign_i_n_page_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:typed_data';

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  static const String routeName = 'SettingsPage';
  static const String routePath = '/settingsPage';

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isConnecting = false;
  bool _isConnected = false;

  // Settings values
  bool _autoSpeedAdjustment = true;
  bool _collisionWarning = true;
  String? _drivingMode;
  String? _vehicleType;

  // Controllers
  late FormFieldController<String> _drivingModeController;
  late FormFieldController<String> _vehicleTypeController;

  // Validation
  String? _vehicleTypeError;

  // Bluetooth
  BluetoothConnection? _bluetoothConnection;
  String _hc06Address = '00:22:06:01:CE:5A';

  static const String _defaultDrivingMode = 'Normal - Balanced safety and performance';
  static const String _defaultVehicleType = 'Sedan';

  @override
  void initState() {
    super.initState();
    _drivingModeController = FormFieldController<String>(_drivingMode);
    _vehicleTypeController = FormFieldController<String>(_vehicleType);
    _loadSettings();
    _initBluetoothConnection();
  }

  Future<void> _initBluetoothConnection() async {
    try {
      // Check if Bluetooth is enabled
      bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (!isEnabled!) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }

      // Connect to HC-06
      await _connectToHC06();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bluetooth error: $e')),
        );
      }
    }
  }

  Future<void> _connectToHC06() async {
    if (!mounted) return;

    setState(() {
      _isConnecting = true;
      _isConnected = false;
    });

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(_hc06Address);
      setState(() {
        _bluetoothConnection = connection;
        _isConnected = true;
        _isConnecting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected to HC-06')),
        );
      }

      // Listen for disconnection
      _bluetoothConnection!.input!.listen(null).onDone(() {
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Disconnected from HC-06')),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to HC-06: $e')),
        );
      }
    }
  }

  Future<void> _retryConnection() async {
    if (_bluetoothConnection != null) {
      _bluetoothConnection!.dispose(); // No await needed
    }
    await _connectToHC06();
  }

  Future<void> _sendDrivingMode(String? mode) async {
    if (_bluetoothConnection == null || !_bluetoothConnection!.isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth not connected')),
        );
      }
      return;
    }

    String modeChar;
    switch (mode) {
      case 'Cautious - Maximum safety, conservative alerts':
        modeChar = 'C';
        break;
      case 'Normal - Balanced safety and performance':
        modeChar = 'N';
        break;
      case 'Sport - Performance focused, reduced alerts':
        modeChar = 'S';
        break;
      default:
        modeChar = 'N'; // Fallback to Normal
    }

    try {
      _bluetoothConnection!.output.add(Uint8List.fromList('$modeChar\n'.codeUnits));
      await _bluetoothConnection!.output.allSent;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send mode: $e')),
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSpeedAdjustment = prefs.getBool('autoSpeedAdjustment') ?? true;
      _collisionWarning = prefs.getBool('collisionWarning') ?? true;
      _drivingMode = prefs.getString('drivingMode') ?? _defaultDrivingMode;
      _vehicleType = prefs.getString('vehicleType') ?? _defaultVehicleType;

      _drivingModeController = FormFieldController<String>(_drivingMode);
      _vehicleTypeController = FormFieldController<String>(_vehicleType);

      _isLoading = false;
    });

    // Send initial driving mode to HC-06
    _sendDrivingMode(_drivingMode);
  }

  Future<void> _saveSettings() async {
    if (_vehicleType == null || _vehicleType!.isEmpty) {
      setState(() {
        _vehicleTypeError = 'Please select your vehicle type.';
      });
      return;
    } else {
      setState(() {
        _vehicleTypeError = null;
      });
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('autoSpeedAdjustment', _autoSpeedAdjustment);
    await prefs.setBool('collisionWarning', _collisionWarning);
    await prefs.setString('drivingMode', _drivingMode ?? _defaultDrivingMode);
    await prefs.setString('vehicleType', _vehicleType ?? _defaultVehicleType);

    // Send updated driving mode to HC-06
    await _sendDrivingMode(_drivingMode);

    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );
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
      if (_bluetoothConnection != null) {
        _bluetoothConnection!.dispose();
      }
      if (!mounted) return;
      context.pushNamed(SignINPageWidget.routeName);
    }
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('autoSpeedAdjustment');
    await prefs.remove('collisionWarning');
    await prefs.remove('drivingMode');
    await prefs.remove('vehicleType');
    setState(() {
      _autoSpeedAdjustment = true;
      _collisionWarning = true;
      _drivingMode = _defaultDrivingMode;
      _vehicleType = _defaultVehicleType;
      _vehicleTypeError = null;
      _drivingModeController = FormFieldController<String>(_drivingMode);
      _vehicleTypeController = FormFieldController<String>(_vehicleType);
    });
    await _loadSettings();
    await _sendDrivingMode(_drivingMode);
  }

  @override
  void dispose() {
    _bluetoothConnection?.dispose(); // No await needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: FlutterFlowIconButton(
            borderRadius: 20,
            buttonSize: 40,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Settings',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Bluetooth Connection Status
                  _buildConnectionStatusCard(),
                  const SizedBox(height: 16),

                  // Vehicle Settings Section
                  _buildSettingsCard(
                    title: 'Vehicle Settings',
                    children: [
                      _buildSwitchTile(
                        'Auto Speed Adjustment',
                        _autoSpeedAdjustment,
                            (value) => setState(() => _autoSpeedAdjustment = value),
                      ),
                      _buildSwitchTile(
                        'Collision Warning System',
                        _collisionWarning,
                            (value) => setState(() => _collisionWarning = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Driving Mode Section
                  _buildSettingsCard(
                    title: 'Driving Mode',
                    children: [
                      FlutterFlowRadioButton(
                        options: const [
                          'Cautious - Maximum safety, conservative alerts',
                          'Normal - Balanced safety and performance',
                          'Sport - Performance focused, reduced alerts',
                        ],
                        onChanged: (value) {
                          setState(() {
                            _drivingMode = value;
                            _drivingModeController.value = value;
                          });
                          _sendDrivingMode(value); // Send mode to HC-06
                        },
                        controller: _drivingModeController,
                        optionHeight: 40,
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        selectedTextStyle: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        buttonPosition: RadioButtonPosition.left,
                        direction: Axis.vertical,
                        radioButtonColor: FlutterFlowTheme.of(context).primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Type Section
                  _buildSettingsCard(
                    title: 'Vehicle Type',
                    children: [
                      FlutterFlowDropDown<String>(
                        controller: _vehicleTypeController,
                        options: const [
                          'Sedan',
                          'SUV',
                          'Truck',
                          'Compact',
                          'Electric Vehicle',
                        ],
                        onChanged: (value) {
                          setState(() {
                            _vehicleType = value;
                            _vehicleTypeController.value = value;
                            _vehicleTypeError = null;
                          });
                        },
                        width: double.infinity,
                        height: 50,
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        hintText: 'Select your vehicle type',
                        fillColor: Colors.white,
                        elevation: 0,
                        borderWidth: 1,
                        borderRadius: 8,
                        borderColor: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        isOverButton: false,
                        isSearchable: false,
                        isMultiSelect: false,
                        hidesUnderline: true,
                      ),
                      if (_vehicleTypeError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _vehicleTypeError!,
                              style: GoogleFonts.inter(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  FFButtonWidget(
                    onPressed: _isLoading ? null : _saveSettings,
                    text: 'Save Changes',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.all(0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 2,
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reset Button
                  FFButtonWidget(
                    onPressed: _isLoading ? null : _resetToDefaults,
                    text: 'Reset to Default',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.all(0),
                      color: Colors.white,
                      textStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 0,
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout Button
                  FFButtonWidget(
                    onPressed: _showLogoutConfirmationDialog,
                    text: 'Logout',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.all(0),
                      color: Colors.red,
                      textStyle: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 2,
                      borderSide: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildConnectionStatusCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HC-06 Bluetooth',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _isConnecting
                          ? 'Connecting...'
                          : _isConnected
                          ? 'Connected'
                          : 'Disconnected',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _isConnecting
                            ? Colors.orange
                            : _isConnected
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            FFButtonWidget(
              onPressed: _isConnecting ? null : _retryConnection,
              text: 'Retry',
              options: FFButtonOptions(
                width: 100,
                height: 36,
                padding: const EdgeInsets.all(0),
                color: _isConnected ? Colors.green : Colors.blue,
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 2,
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Divider(height: 16, thickness: 1, color: Colors.grey),
            ...children.map((child) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: child,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: FlutterFlowTheme.of(context).primary,
        ),
      ],
    );
  }
}