import 'package:flutter/material.dart';
import '../model/tir.dart';
import 'package:latlong2/latlong.dart';
import '../app/signal_strength.dart';

class NewTirResult {
  final LatLng position;
  final double heading;
  final Strength strength;

  NewTirResult({
    required this.position,
    required this.heading,
    required this.strength,
  });
}

class NewTirPage extends StatefulWidget {
  final LatLng initialPosition;
  final bool isPc;

  const NewTirPage({
    super.key,
    required this.initialPosition,
    required this.isPc,
  });

  @override
  State<NewTirPage> createState() => _NewTirPageState();
}

class _NewTirPageState extends State<NewTirPage> {
  late LatLng position;
  double heading = 0;
  Strength strength = Strength.Moyen;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau tir')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.isPc)
              Text('Position : ${position.latitude}, ${position.longitude}'),

            const SizedBox(height: 16),

            Text('Heading : ${heading.round()}°'),
            Slider(
              min: 0,
              max: 360,
              value: heading,
              onChanged: (v) => setState(() => heading = v),
            ),

            const SizedBox(height: 16),

            DropdownButton<Strength>(
              value: strength,
              items: Strength.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name),
                );
              }).toList(),
              onChanged: (v) => setState(() => strength = v!),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  NewTirResult(
                    position: position,
                    heading: heading,
                    strength: strength,
                  ),
                );
              },
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}