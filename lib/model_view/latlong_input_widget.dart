import 'package:flutter/material.dart';
//import 'package:flutter/services.dart'; // pour textinputformater
import 'package:latlong2/latlong.dart';

class LatLonInput extends StatefulWidget {
  final ValueChanged<LatLng> onPositionValidated;

  const LatLonInput({super.key, required this.onPositionValidated});

  @override
  State<LatLonInput> createState() => _LatLonInputState();
}

class _LatLonInputState extends State<LatLonInput> {
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  final _latFocus = FocusNode();
  final _lonFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _latFocus.addListener(_onFocusLost);
    _lonFocus.addListener(_onFocusLost);
  }

  void _onFocusLost() {
    if (!_latFocus.hasFocus && !_lonFocus.hasFocus) {
      _validateAndEmit();
    }
  }

  void _validateAndEmit() {
    final lat = double.tryParse(_latController.text.replaceAll(',', '.'));
    final lon = double.tryParse(_lonController.text.replaceAll(',', '.'));

    if (lat == null || lon == null) return;
    if (lat < -90 || lat > 90) return;
    if (lon < -180 || lon > 180) return;

    debugPrint("de saisie $lat, $lon");

    widget.onPositionValidated(LatLng(lat, lon));
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    _latFocus.dispose();
    _lonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _latController,
          focusNode: _latFocus,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Latitude'),
        ),
        TextField(
          controller: _lonController,
          focusNode: _lonFocus,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Longitude'),
        ),
      ],
    );
  }
}