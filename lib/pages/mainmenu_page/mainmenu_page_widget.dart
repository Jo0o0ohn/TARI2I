import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainmenuPageModel());
    _fetchUserName();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
                    // Greeting Section
                    _buildGreetingSection(),
                    const SizedBox(height: 24),

                    // Main Card with Speed Information
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: _buildSpeedCard(context),
                    ),
                    const SizedBox(height: 24),

                    // Services Grid Section
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
    return Container(
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
              // Car Image
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

              // Speed Info - Centered vertically
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
                        // Speed Header
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
                                color: const Color(0xFF00FFC4),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FFC4).withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Speed Display - Centered in the available space
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '65',
                                style: GoogleFonts.inter(
                                  fontSize: 60,
                                  fontWeight: FontWeight.w800,
                                  color: FlutterFlowTheme.of(context).primary,
                                  height: 0.9,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'KILOMETER PER HOUR',
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

class _SpeedScalePainter extends CustomPainter {
  final int currentSpeed;
  final int maxSpeed;

  const _SpeedScalePainter({required this.currentSpeed, required this.maxSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00FFC4), Color(0xFF0075FF)],
      ).createShader(Rect.fromLTRB(0, 0, size.width, 0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);
    canvas.drawPath(path, backgroundPaint);

    final activePath = Path();
    activePath.moveTo(0, size.height / 2);
    activePath.lineTo(size.width * (currentSpeed / maxSpeed), size.height / 2);
    canvas.drawPath(activePath, activePaint);

    final indicatorPaint = Paint()
      ..color = const Color(0xFF00FFC4)
      ..style = PaintingStyle.fill;

    final indicatorX = size.width * (currentSpeed / maxSpeed);
    canvas.drawCircle(
      Offset(indicatorX, size.height / 2),
      6,
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}