import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'mainmenu_page_model.dart';
export 'mainmenu_page_model.dart';
import 'package:flutter/services.dart';

class MainmenuPageWidget extends StatefulWidget {
  const MainmenuPageWidget({super.key});

  static String routeName = 'MainmenuPage';
  static String routePath = '/mainmenuPage';

  @override
  State<MainmenuPageWidget> createState() => _MainmenuPageWidgetState();
}

class _MainmenuPageWidgetState extends State<MainmenuPageWidget> {
  late MainmenuPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? userName;
  bool _loading = true;
  double _currentSpeed = 0.0;
  BluetoothConnection? _connection;
  bool _isBluetoothConnected = false;
  bool _isConnecting = false;
  StreamSubscription<String>? _speedSubscription;
  DateTime? _lastConnectionAttempt;
  Timer? _connectionTimeoutTimer;
  final _maxRetryDuration = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainmenuPageModel());
    _fetchUserName();
    _initBluetooth();
  }

  @override
  void dispose() {
    _speedSubscription?.cancel();
    _connection?.dispose();
    _connectionTimeoutTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    _connectionTimeoutTimer?.cancel();

    _connectionTimeoutTimer = Timer(_maxRetryDuration, () {
      if (mounted && !_isBluetoothConnected) {
        setState(() {
          _isConnecting = false;
          _isBluetoothConnected = false;
        });
        // Removed SnackBar
      }
    });

    setState(() {
      _isConnecting = true;
      _lastConnectionAttempt = DateTime.now();
    });

    try {
      bool enabled = await FlutterBluetoothSerial.instance.isEnabled ?? false;
      if (!enabled) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }

      _connection = await BluetoothConnection.toAddress('00:22:06:01:CE:5A');

      _connectionTimeoutTimer?.cancel();

      setState(() {
        _isBluetoothConnected = true;
        _isConnecting = false;
      });

      // Removed connected SnackBar

      _speedSubscription = _connection!.input!
          .map((data) => String.fromCharCodes(data).trim())
          .listen((data) {
        try {
          if (data.startsWith('Speed: ')) {
            final speedStr = data.split(' ')[1];
            final speed = double.tryParse(speedStr) ?? _currentSpeed;
            if (mounted) {
              setState(() => _currentSpeed = speed);
            }
          }
          else if (double.tryParse(data) != null) {
            final speed = double.parse(data);
            if (mounted) {
              setState(() => _currentSpeed = speed);
            }
          }
        } catch (e) {
          debugPrint('Error parsing speed data: $e');
        }
      }, onError: (error) {
        debugPrint('Bluetooth error: $error');
        _reconnectBluetooth();
      }, onDone: () {
        debugPrint('Bluetooth disconnected');
        _reconnectBluetooth();
      });

    } catch (e) {
      debugPrint('Bluetooth connection error: $e');
      _reconnectBluetooth();
    }
  }
  Future<void> _reconnectBluetooth() async {
    if (_isConnecting) return;

    if (_lastConnectionAttempt != null &&
        DateTime.now().difference(_lastConnectionAttempt!) > _maxRetryDuration) {
      if (mounted) {
        setState(() {
          _isBluetoothConnected = false;
          _isConnecting = false;
        });
      }
      return;
    }

    setState(() {
      _isBluetoothConnected = false;
      _isConnecting = false;
    });

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      _initBluetooth();
    }
  }
  Future<void> _retryConnection() async {
    if (_isConnecting) return;

    _connectionTimeoutTimer?.cancel();

    setState(() {
      _isConnecting = true;
      _lastConnectionAttempt = DateTime.now();
    });

    try {
      _connection?.dispose();
      _connection = null;
      _speedSubscription?.cancel();
      _speedSubscription = null;

      await _initBluetooth();
    } catch (e) {
      debugPrint('Retry connection error: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isBluetoothConnected = false;
        });
      }
    }
  }
  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        userName = 'Guest';
        _loading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = userDoc.data()?['fullname'] ?? 'User';
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      setState(() {
        userName = 'User';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(12.0),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(),
                    const SizedBox(height: 24),
                    _buildSpeedCard(context),
                    const SizedBox(height: 24),
                    _buildServicesHeader(),
                    const SizedBox(height: 12),
                    _buildServicesGrid(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        _loading ? '...' : 'Hello $userName!',
        style: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpeedCard(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isBluetoothConnected
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isBluetoothConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: _isBluetoothConnected ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnecting
                          ? 'Connecting...'
                          : _isBluetoothConnected
                          ? 'Connected to HC-06'
                          : 'Disconnected',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isBluetoothConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                if (!_isBluetoothConnected || _isConnecting)
                  TextButton(
                    onPressed: _retryConnection,
                    child: const Text('Retry', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned(
                        left: -60,
                        top: 0,
                        bottom: 0,
                        width: constraints.maxWidth * 0.5,
                        child: Image.asset(
                          'assets/images/fast-sport-car-silhouette-logo-vector-48573848.jpg',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Positioned(
                        right: 35,
                        top: 0,
                        bottom: 0,
                        width: constraints.maxWidth * 0.45,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'CURRENT SPEED',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black.withOpacity(0.6),
                                          letterSpacing: 1.0,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _isBluetoothConnected && _currentSpeed > 0
                                            ? const Color(0xFF00FFC4)
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isBluetoothConnected && _currentSpeed > 0
                                                ? const Color(0xFF00FFC4)
                                                : Colors.grey).withOpacity(0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _isBluetoothConnected
                                            ? _currentSpeed.toStringAsFixed(1) // Show 1 decimal place
                                            : '--',
                                        style: GoogleFonts.inter(
                                          fontSize: 60,
                                          fontWeight: FontWeight.w800,
                                          color: _isBluetoothConnected
                                              ? FlutterFlowTheme.of(context).primary
                                              : Colors.grey,
                                          height: 0.9,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'KILOMETERS PER HOUR',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black.withOpacity(0.6),
                                          letterSpacing: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Services',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildServiceButton(
          icon: Icons.search,
          label: 'Search & Predict',
          color: const Color(0xFF4285F4),
          onTap: () => context.pushNamed(PredictionPageWidget.routeName),
        ),
        _buildServiceButton(
          icon: Icons.settings,
          label: 'Settings',
          color: const Color(0xFF0F9D58),
          onTap: () => context.pushNamed(SettingsPageWidget.routeName),
        ),
        _buildServiceButton(
          icon: Icons.info_outline,
          label: 'About',
          color: const Color(0xFFFBBC05),
          onTap: () => context.pushNamed(AboutPageWidget.routeName),
        ),
        _buildServiceButton(
          icon: Icons.warning,
          label: 'Emergency',
          color: const Color(0xFFEA4335),
          onTap: () => context.pushNamed(EmergencypageWidget.routeName),
        ),
      ],
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}