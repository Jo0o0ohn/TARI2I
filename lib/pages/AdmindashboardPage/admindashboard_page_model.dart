import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'admindashboard_page_widget.dart' show AdmindashboardPageWidget;
import 'package:flutter/material.dart';

class Alert {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final String sentBy; // new field

  Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.sentBy,
  });
}

enum AlertType { warning, info }

class AdmindashboardPageModel extends FlutterFlowModel<AdmindashboardPageWidget> {
  /// State fields for stateful widgets in this page.

  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;

  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  @override
  void initState(BuildContext context) {
    // Optionally initialize text controllers or other setup here.
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }

  /// Stream to listen for alerts from Firestore
  Stream<List<Alert>> alertsStream() {
    return FirebaseFirestore.instance
        .collection('alerts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Alert(
          id: doc.id,
          title: data['title'] ?? 'No Title',
          description: data['description'] ?? 'No Description',
          type: (data['type'] == 'info') ? AlertType.info : AlertType.warning,
          sentBy: data['sentBy'] ?? 'Unknown'
        );
      }).toList();
    });
  }

  /// Delete alert from Firestore by id
  Future<void> deleteAlert(String id) async {
    await FirebaseFirestore.instance.collection('alerts').doc(id).delete();
  }
}
