import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart' as ff;
import '/flutter_flow/flutter_flow_widgets.dart';
import 'prediction_page_model.dart';
import 'package:flutter_google_places_hoc081098/src/google_maps_webservice/src/places.dart';


const kGoogleApiKey = "AIzaSyA6AVyXcCNFeUDVL51juH479oCj4TDKVgQ"; // Replace with your actual API key

class PredictionPageWidget extends StatefulWidget {
  const PredictionPageWidget({super.key});
  static const String routeName = '/predictionPage';
  static const String routePath = '/prediction_page';
  @override
  State<PredictionPageWidget> createState() => _PredictionPageWidgetState();
}

class _PredictionPageWidgetState extends State<PredictionPageWidget> {
  late PredictionPageModel _model;
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng _currentLocation = const LatLng(37.7749, -122.4194);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showMapsButton = false;

  // Route information
  String _distance = '';
  String _duration = '';
  String _trafficCondition = 'Light';
  String _weatherCondition = 'Clear';
  String _eta = '';
  List<RouteOption> _routeOptions = [];
  RouteOption? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _model = ff.createModel(context, () => PredictionPageModel());

    _model.textController1 = TextEditingController();
    _model.textFieldFocusNode1 = FocusNode();
    _model.textController2 = TextEditingController();
    _model.textFieldFocusNode2 = FocusNode();
    _model.textController3 = TextEditingController();
    _model.textFieldFocusNode3 = FocusNode();

    final now = DateTime.now();
    _model.textController2.text = DateFormat('MMM dd, yyyy').format(now);
    _model.textController3.text = DateFormat('hh:mm a').format(now);

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are permanently denied.")));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentLocation,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    if (mapController != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15),
      );
    }
  }

  Future<void> _handleSearch() async {
    try {
      // Show autocomplete UI
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        mode: Mode.overlay,
        language: "en",
        // Remove the hardcoded country component
        // components: [Component(Component.country, "us")],  // Remove this line
        location: _currentLocation != null
            ? Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude)
            : null,
        radius: _currentLocation != null ? 50000 : null,  // 50km radius around current location
      );

      if (p == null) return; // User cancelled

      // Get place details
      final placesUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?placeid=${p.placeId}&key=$kGoogleApiKey');
      final placesResponse = await http.get(placesUrl);
      final placesData = json.decode(placesResponse.body);

      if (placesData['status'] == 'OK') {
        final result = placesData['result'];
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];
        final placeName = result['name'] ?? p.description ?? 'Selected Place';

        setState(() {
          // Update text field
          _model.textController1.text = placeName;

          // Update markers
          _markers.removeWhere((m) => m.markerId.value == 'destination');
          _markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: placeName),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );

          // Animate camera to include current + destination
          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList([_currentLocation, LatLng(lat, lng)]),
              100.0,
            ),
          );
        });
      } else {
        throw Exception('Google Places API Error: ${placesData['status']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching place: ${e.toString()}")),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  Future<void> _calculateRoute() async {
    if (_markers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a destination first.")));
      return;
    }

    final destination = _markers.firstWhere(
            (m) => m.markerId.value == 'destination').position;

    try {
      final dateStr = _model.textController2.text;
      final timeStr = _model.textController3.text;
      final dateTimeStr = "$dateStr $timeStr";
      final departureTime = DateFormat('MMM dd, yyyy hh:mm a').parse(dateTimeStr);
      final departureTimestamp = departureTime.millisecondsSinceEpoch ~/ 1000;

      final directionsUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?'
              'origin=${_currentLocation.latitude},${_currentLocation.longitude}&'
              'destination=${destination.latitude},${destination.longitude}&'
              'departure_time=$departureTimestamp&'
              'traffic_model=best_guess&'
              'alternatives=true&'
              'key=$kGoogleApiKey');

      final response = await http.get(directionsUrl);
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
        setState(() {
          _polylines.clear();
          _routeOptions.clear();

          for (int i = 0; i < data['routes'].length; i++) {
            final route = data['routes'][i];
            final points = route['overview_polyline']['points'];
            final legs = route['legs'][0];
            final distance = legs['distance']['text'];
            final duration = legs['duration_in_traffic']?['text'] ?? legs['duration']['text'];

            final decoded = _decodePolyline(points);
            final coordinates = decoded.map((p) => LatLng(p['lat']!, p['lng']!)).toList();

            final polyline = Polyline(
              polylineId: PolylineId('route$i'),
              points: coordinates,
              color: i == 0 ? Colors.blue : Colors.grey,
              width: i == 0 ? 5 : 3,
            );

            _polylines.add(polyline);

            _routeOptions.add(RouteOption(
              id: i,
              distance: distance,
              duration: duration,
              coordinates: coordinates,
              summary: route['summary'] ?? 'Route ${i + 1}',
              polyline: polyline,
            ));
          }

          _selectedRoute = _routeOptions.first;
          _updateRouteInfo(_selectedRoute!);

          mapController.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList(_selectedRoute!.coordinates),
              100.0,
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not calculate route.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error calculating route: ${e.toString()}")));
    }
  }

  List<Map<String, double>> _decodePolyline(String encoded) {
    List<Map<String, double>> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add({
        'lat': lat / 1E5,
        'lng': lng / 1E5,
      });
    }
    return poly;
  }

  void _updateRouteInfo(RouteOption route) {
    setState(() {
      _distance = route.distance;
      _duration = route.duration;

      final dateStr = _model.textController2.text;
      final timeStr = _model.textController3.text;
      final dateTimeStr = "$dateStr $timeStr";
      final departureTime = DateFormat('MMM dd, yyyy hh:mm a').parse(dateTimeStr);

      final durationParts = route.duration.split(' ');
      int totalMinutes = 0;
      for (int i = 0; i < durationParts.length; i++) {
        if (durationParts[i] == 'hour' || durationParts[i] == 'hours') {
          totalMinutes += int.parse(durationParts[i-1]) * 60;
        } else if (durationParts[i] == 'mins' || durationParts[i] == 'min') {
          totalMinutes += int.parse(durationParts[i-1]);
        }
      }

      final eta = departureTime.add(Duration(minutes: totalMinutes));
      _eta = DateFormat('hh:mm a').format(eta);

      final distanceKm = double.parse(route.distance.replaceAll(' km', ''));
      final durationHours = totalMinutes / 60;
      final speed = distanceKm / durationHours;

      if (speed < 30) {
        _trafficCondition = 'Heavy';
      } else if (speed < 50) {
        _trafficCondition = 'Moderate';
      } else {
        _trafficCondition = 'Light';
      }

      _polylines = _polylines.map((p) {
        return p.polylineId == route.polyline.polylineId
            ? p.copyWith(colorParam: Colors.blue, widthParam: 5)
            : p.copyWith(colorParam: Colors.grey, widthParam: 3);
      }).toSet();
    });
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3E7C37),
              onPrimary: Colors.white,
              onSurface: const Color(0xFF3E7C37),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3E7C37),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF3E7C37),
              onPrimary: Colors.white,
              onSurface: const Color(0xFF3E7C37),
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Route Prediction',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
              fontSize: 22.0,
            ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              trafficEnabled: true,
            ),

            // Search and route planning panel
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 48.0, 16.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8.0,
                            color: Color(0x33000000),
                            offset: Offset(0.0, 2.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const SizedBox(height: 8.0),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: TextFormField(
                                  controller: _model.textController1,
                                  focusNode: _model.textFieldFocusNode1,
                                  autofocus: false,
                                  textInputAction: TextInputAction.search,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    hintText: 'Search destination',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                      fontFamily: 'Inter',
                                      color: const Color(0xFF3E7C37),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                        color: FlutterFlowTheme.of(context).dateTimePickerColor,
                                      ),
                                    ),
                                    contentPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 12.0, 16.0, 12.0),
                                    prefixIcon: const Icon(Icons.search, color: Color(0xFF3E7C37), size: 30.0,),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF3E7C37), // Green text color
                                  ),

                                  onTap: _handleSearch,
                                  readOnly: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: TextFormField(
                                        controller: _model.textController2,
                                        focusNode: _model.textFieldFocusNode2,
                                        readOnly: true,
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context).dateTimePickerColor,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Date',
                                          hintStyle: TextStyle(
                                            color: FlutterFlowTheme.of(context).dateTimePickerHint,
                                          ),
                                          prefixIcon: Icon(Icons.calendar_today, color: const Color(0xFF3E7C37)),
                                          filled: true,
                                          fillColor: FlutterFlowTheme.of(context).dateTimePickerBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: FlutterFlowTheme.of(context).dateTimePickerColor,
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          final pickedDate = await _selectDate(context);
                                          if (pickedDate != null) {
                                            setState(() {
                                              _model.textController2.text =
                                                  DateFormat('MMM dd, yyyy').format(pickedDate);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Container(
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: TextFormField(
                                        controller: _model.textController3,
                                        focusNode: _model.textFieldFocusNode3,
                                        readOnly: true,
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context).dateTimePickerColor,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Time',
                                          hintStyle: TextStyle(
                                            color: FlutterFlowTheme.of(context).dateTimePickerHint,
                                          ),
                                          prefixIcon: Icon(Icons.access_time, color: const Color(0xFF3E7C37)),
                                          filled: true,
                                          fillColor: FlutterFlowTheme.of(context).dateTimePickerBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color: const Color(0xFF3E7C37),
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          final pickedTime = await _selectTime(context);
                                          if (pickedTime != null) {
                                            setState(() {
                                              final now = DateTime.now();
                                              final dt = DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                  pickedTime.hour,
                                                  pickedTime.minute);
                                              _model.textController3.text =
                                                  DateFormat('hh:mm a').format(dt);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            FFButtonWidget(
                              onPressed: () async {
                                await _calculateRoute(); // your existing method to calculate/predict route
                                if (mounted) {
                                  setState(() {
                                    _showMapsButton = true; // show the "Open in Google Maps" button
                                  });
                                }
                              },
                              text: 'Predict Route Time',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 44.0,
                                padding: const EdgeInsets.all(8.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontWeight: FontWeight.w600,
                                ),
                                elevation: 0.0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0,
                                ),

                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12.0),
                  if (_showMapsButton)
                    Align(
                      alignment: Alignment.topRight, // 👈 Position to bottom right
                      child: Padding(
                        padding: const EdgeInsets.only(right: 25.0, bottom: 185.0), // 👈 Padding from edges
                        child: SizedBox(
                          width: 160, // 👈 Adjust width as needed
                          height: 40,
                          child: FFButtonWidget(
                            onPressed: () async {
                              if (_selectedRoute == null || _markers.length < 2) return;

                              final destination = _markers.firstWhere(
                                      (m) => m.markerId.value == 'destination').position;

                              final url = 'https://www.google.com/maps/dir/?api=1&'
                                  'origin=${_currentLocation.latitude},${_currentLocation.longitude}&'
                                  'destination=${destination.latitude},${destination.longitude}&'
                                  'travelmode=driving&'
                                  'dir_action=navigate';

                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Could not launch Google Maps")),
                                );
                              }
                            },
                            text: 'Open Maps',
                            options: FFButtonOptions(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              color: FlutterFlowTheme.of(context).secondary,
                              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              elevation: 2.0,
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 16.0, 16.0, 32.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8.0,
                            color: Color(0x33000000),
                            offset: Offset(0.0, -2.0),
                          )
                        ],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Route options selector
                            if (_routeOptions.length > 1)
                              Column(
                                children: [
                                  SizedBox(
                                    height: 50,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _routeOptions.length,
                                      itemBuilder: (context, index) {
                                        final option = _routeOptions[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: ChoiceChip(
                                            label: Text(
                                              'Route ${index + 1} (${option.duration})',
                                              style: TextStyle(
                                                color: _selectedRoute?.id == option.id
                                                    ? Colors.white
                                                    : FlutterFlowTheme.of(context).primaryText,
                                              ),
                                            ),
                                            selected: _selectedRoute?.id == option.id,
                                            selectedColor: FlutterFlowTheme.of(context).primary,
                                            onSelected: (selected) {
                                              if (selected) {
                                                setState(() {
                                                  _selectedRoute = option;
                                                  _updateRouteInfo(option);
                                                  _showMapsButton = true; // <- show the button after predicting route
                                                });
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),

                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Distance',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                        fontFamily: 'Inter Tight',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          _distance.isNotEmpty ? _distance.split(' ')[0] : '--',
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall
                                              .override(
                                            fontFamily: 'Inter Tight',
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 8.0, 0.0, 0.0),
                                          child: Text(
                                            _distance.isNotEmpty ? _distance.split(' ')[1] : '',
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                              fontFamily: 'Inter Tight',
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'ETA',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                        fontFamily: 'Inter Tight',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _eta.isNotEmpty ? _eta : '--:--',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                        fontFamily: 'Inter Tight',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 1.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Traffic Conditions',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 12.0,
                                          height: 12.0,
                                          decoration: BoxDecoration(
                                            color: _trafficCondition == 'Heavy'
                                                ? FlutterFlowTheme.of(context).error
                                                : _trafficCondition == 'Moderate'
                                                ? FlutterFlowTheme.of(context).warning
                                                : FlutterFlowTheme.of(context).success,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          _trafficCondition,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      _duration.isNotEmpty ? _duration : '--',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Weather',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          _weatherCondition.contains('Rain')
                                              ? Icons.water_drop
                                              : _weatherCondition.contains('Cloud')
                                              ? Icons.cloud
                                              : Icons.wb_sunny,
                                          color: FlutterFlowTheme.of(context).info,
                                          size: 16.0,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          _weatherCondition,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Map controls
            Align(
              alignment: const AlignmentDirectional(1.0, 0.3),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 76.8,
                  height: 180.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x33000000),
                        offset: Offset(2.0, 2.0),
                      )
                    ],
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlutterFlowIconButton(
                          borderRadius: 22.0,
                          buttonSize: 44.0,
                          fillColor: FlutterFlowTheme.of(context)
                              .primaryBackground,
                          icon: Icon(
                            Icons.add,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                        FlutterFlowIconButton(
                          borderRadius: 22.0,
                          buttonSize: 44.0,
                          fillColor: FlutterFlowTheme.of(context)
                              .primaryBackground,
                          icon: Icon(
                            Icons.remove,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                        FlutterFlowIconButton(
                          borderRadius: 22.0,
                          buttonSize: 44.0,
                          fillColor: FlutterFlowTheme.of(context)
                              .primaryBackground,
                          icon: Icon(
                            Icons.my_location,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RouteOption {
  final int id;
  final String distance;
  final String duration;
  final List<LatLng> coordinates;
  final String summary;
  final Polyline polyline;

  RouteOption({
    required this.id,
    required this.distance,
    required this.duration,
    required this.coordinates,
    required this.summary,
    required this.polyline,
  });
}