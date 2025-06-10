import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';

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

  static const String _defaultDrivingMode =
      'Normal - Balanced safety and performance';

  @override
  void initState() {
    super.initState();
    _drivingModeController = FormFieldController<String>(_drivingMode);
    _vehicleTypeController = FormFieldController<String>(_vehicleType);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSpeedAdjustment = prefs.getBool('autoSpeedAdjustment') ?? true;
      _collisionWarning = prefs.getBool('collisionWarning') ?? true;
      _drivingMode = prefs.getString('drivingMode') ?? _defaultDrivingMode;
      _vehicleType = prefs.getString('vehicleType');

      _drivingModeController = FormFieldController<String>(_drivingMode);
      _vehicleTypeController = FormFieldController<String>(_vehicleType);

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    // Validation: require vehicle type
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
    if (_drivingMode != null) {
      await prefs.setString('drivingMode', _drivingMode!);
    } else {
      await prefs.setString('drivingMode', _defaultDrivingMode);
    }
    if (_vehicleType != null) {
      await prefs.setString('vehicleType', _vehicleType!);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );
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
      _vehicleType = null;
      _vehicleTypeError = null;
      _drivingModeController = FormFieldController<String>(_drivingMode);
      _vehicleTypeController = FormFieldController<String>(null);
    });
    await _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 20,
            buttonSize: 40,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Settings',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: FlutterFlowTheme.of(context).secondaryBackground,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
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
                        },
                        controller: _drivingModeController,
                        optionHeight: 40,
                        textStyle: FlutterFlowTheme.of(context).bodyMedium,
                        selectedTextStyle:
                        FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
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
                        textStyle: FlutterFlowTheme.of(context).bodyMedium,
                        hintText: 'Select your vehicle type',
                        fillColor:
                        FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 2,
                        borderWidth: 1,
                        borderRadius: 8,
                        borderColor: Colors.grey,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
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
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
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
                      textStyle:
                      FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Inter Tight',
                        color: FlutterFlowTheme.of(context)
                            .secondaryBackground,
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
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      textStyle: FlutterFlowTheme.of(context).titleSmall,
                      elevation: 0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1,
                      ),
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

  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontFamily: 'Inter Tight',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 16, thickness: 1),
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
          style: FlutterFlowTheme.of(context).bodyMedium,
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