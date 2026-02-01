import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/location_provider.dart';
import '../model/geo_utils.dart';
import '../app/signal_strength.dart';
import '../app/tir_Dto_input.dart';

class MobileTirInputScreen extends StatefulWidget {

  const MobileTirInputScreen({super.key,});

  @override
  State<MobileTirInputScreen> createState() => _MobileTirInputScreenState();
}

class _MobileTirInputScreenState extends State<MobileTirInputScreen>{

  //valeurs par défaut
  double _azimut = 0.0;

  final Map<Strength, String> strengthLabels = {
    Strength.Tres_faible: "Très faible",
    Strength.Faible: "Faible",
    Strength.Moyen: "Moyen",
    Strength.Fort: "Fort",
    Strength.Tres_fort: "Très fort",
  };

  //définition d'une force de signal par défaut
  Strength _selectedForce = Strength.Moyen;

  @override
  Widget build(BuildContext context) {

    final location = context.watch<LocationProvider>();
    final LatLng? positionCourante = location.currentLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau tir')),
      body: Padding(
      padding: const EdgeInsets.fromLTRB(16,20,16,30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nouveau tir", style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 12),

            // affiche la position au format Latitude/Longitude
            Text(
              "Position courante : "
              "${positionCourante?.latitude.toStringAsFixed(6)}, "
              "${positionCourante?.longitude.toStringAsFixed(6)}",
            ),

            // affiche la position au format MGRS (long)
            Text(
              "MGRS : "
                  "${MGRS(positionCourante!)}",
            ),

            const Text(
              "Azimut",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Entrez l’azimut (0.0° à 360°)",
              ),
              onChanged: (value) {
                setState(() {
                  _azimut = double.tryParse(value) ?? 0.0;
                });
              },
            ),

            const SizedBox(height: 25),

            // ---- Force du signal ----
            const Text(
              "Force du signal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: Strength.values.map((force) {
                return ChoiceChip(
                  label: Text(strengthLabels[force]!),
                  selected: _selectedForce == force,
                  onSelected: (selected) {
                    setState(() {
                      _selectedForce = force;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            Center(
              child: ElevatedButton(
                child: const Text("Valider"),
                onPressed: () {
                  // Création du tir_Dto_input pour le retourner à MissionMap

                  if( _azimut < 0.0 ||  _azimut >360.0) {
                    _showErreurRangeAzimut();
                    return;
                  }

                  final dto = TirInputDTO(
                      azimut: _azimut,
                      forceSignal: _selectedForce,
                  );

                  Navigator.pop(
                      context,
                      dto,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErreurRangeAzimut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Azimut non conforme'),
        content: const Text(
          'La valeur doit être comprise entre 0.0° et 360°',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } // _showErreurPositionManquante
}
