import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

/* class PredictionPageModel extends FlutterFlowModel<PredictionPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();
  }
}
*/
class PredictionPageModel extends FlutterFlowModel {
  TextEditingController? textController1;
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController2;
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController3;
  FocusNode? textFieldFocusNode3;

  void initState(BuildContext context) {
    textController1 ??= TextEditingController();
    textFieldFocusNode1 ??= FocusNode();
    textController2 ??= TextEditingController();
    textFieldFocusNode2 ??= FocusNode();
    textController3 ??= TextEditingController();
    textFieldFocusNode3 ??= FocusNode();
  }

  void dispose() {
    textController1?.dispose();
    textFieldFocusNode1?.dispose();
    textController2?.dispose();
    textFieldFocusNode2?.dispose();
    textController3?.dispose();
    textFieldFocusNode3?.dispose();
  }
}
