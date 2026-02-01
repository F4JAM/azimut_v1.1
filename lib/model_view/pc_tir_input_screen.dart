import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:latlong2/latlong.dart';

import '../providers/location_provider.dart';
import '../providers/mission_provider.dart';
import '../model/geo_utils.dart';
import '../app/signal_strength.dart';
import '../app/tir_Dto_input.dart';
import 'pc_mgrs_input_widget.dart';

/* Écran de saisie d'un nouveau tir par le PC. A la différence du mode
 * Équipe Mobile, il faut ici choisir l'équipe et saisir les coordonnées MGRS
 * qu'elle a transmise par radio.
 */


class PcTirInputScreen extends StatefulWidget {

  const PcTirInputScreen({super.key,});

  @override
  State<PcTirInputScreen> createState() => _PcTirInputScreenState();
}

class _PcTirInputScreenState extends State<PcTirInputScreen>{

  //valeurs par défaut
  double _azimut = 0.0;

  String _initialGzd = '';
  String _initialSquare = '';

  // pour remplacer l'enum par du texte
  final Map<Strength, String> strengthLabels = {
    Strength.Tres_faible: "Très faible",
    Strength.Faible: "Faible",
    Strength.Moyen: "Moyen",
    Strength.Fort: "Fort",
    Strength.Tres_fort: "Très fort",
  };

  //définition d'une force de signal par défaut
  // initialement défini en final mais du coup ... c'était définitif !
  // on essaye sans
  Strength _strength = Strength.Moyen;
  Strength _selectedForce = Strength.Moyen;

  // Équipe concernée, null par défaut.
  // doit être déclarée au niveau du State, sinon elle est remise à
  // null à chaque build
  String? equipeTir;
  LatLng? _positionEquipe;

  String? _mgrsEquipe;

  void _onPositionValidated(LatLng position) {
    setState(() {
      _positionEquipe = position;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = context.read<LocationProvider>();
      final pos = location.currentLocation;

      if (pos != null) {
        final parts = pos.toMGRSString().split(' ');
        setState(() {
          _initialGzd = parts[0];
          _initialSquare = parts[1];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // récupère la mission depuis le context puis les noms des équipes
    final mission = context.read<MissionProvider>();
    // equipesIds est une List<String>
    final equipesIds = mission.equipeIds;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau tir')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,20,16,30),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 5),

              /******** SELECTION DE L'ÉQUIPE *********/
              Text("Nouveau tir de : ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(height: 5),

              DropdownButton<String>(
              value: equipeTir,
              hint: Text('Sélectionner l\'équipe'),
              onChanged: (String? value) {
                setState(() {
                  equipeTir = value!;
                });
              },
              items: equipesIds.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

              const SizedBox(height: 15),

              /******** SAISIE DE LA POSITION DE L'ÉQUIPE *********/
              const Text(
                "Coordonnée déclarée par l’équipe (MGRS 100m, 2x3 chiffres)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              /*** inital
              MGRSInput(
                  onPositionValidated: _onPositionValidated,
              ),
              */

              MGRSInput(
                initialGzd: _initialGzd,
                initialSquare: _initialSquare,
                onPositionValidated: (latLng) {
                  debugPrint('📍 Position validée : $latLng');
                  setState(() {
                    _positionEquipe = latLng;
                  });
                },
              ),


            const SizedBox(height: 5),

              /******** SAISIE DE L'AZIMUT *********/
            const Text(
              "Azimut",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextField(
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: "Entrez l’azimut (0.0° à 360°)",
              ),
              onChanged: (value) {
                setState(() {
                  _azimut = double.tryParse(value) ?? 0.0;
                });
              },
              onSubmitted: (_) {
                FocusScope.of(context).unfocus(); // cache le clavier
              },

            ),

              const SizedBox(height: 15),

           /******** SAISIE DE LA FORCE DU SIGNAL *********/
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

            /******** VALIDATION *********/
            Center(
              child: ElevatedButton(
                child: const Text("Valider le tir"),
                onPressed: () {
                  _onValiderTir();
                  // Création du tir_Dto_input pour le retourner à MissionMap
                  /*final dto = TirInputDTO(
                    equipeId: equipeTir,
                    position: _positionEquipe,
                    azimut: _azimut,
                    forceSignal: _selectedForce,
                  );
                  debugPrint('🎯 Tir créé avec position $_positionEquipe');
                  Navigator.pop(
                    context,
                    dto,
                  );*/
                },// onPressed
              ),
            ),
           ],
          ),
        ),
      ),
    );
  }

  void _creerTirDTO(){
    final dto = TirInputDTO(
      equipeId: equipeTir,
      position: _positionEquipe,
      azimut: _azimut,
      forceSignal: _selectedForce,
    );
    debugPrint('🎯 Tir créé avec position $_positionEquipe');
    Navigator.pop(
      context,
      dto,
    );
  }

  void _onValiderTir() {
    if (equipeTir == null) {
      _showErreurEquipeNonSelectionnee();
      return;
    }
    if (_positionEquipe == null) {
      _showErreurPositionManquante();
      return;
    }

    if( _azimut < 0.0 ||  _azimut >360.0) {
      _showErreurRangeAzimut();
      return;
    }

    _creerTirDTO();
  }

  void _showErreurEquipeNonSelectionnee() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Équipe manquante'),
        content: const Text(
          'Aucune équipe n’a été sélectionnée.\n\n'
              'Veuillez sélectionner une équipe avant de valider le tir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } // _showErreurEquipeNonSelectionnee

  void _showErreurPositionManquante() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Position manquante'),
        content: const Text(
          'La position de l’équipe n’est pas définie.',
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