/* Saisie d'un waypoint donné par le PC (ou pas) sous la forme d'une
 * coordonnées MGRS. Le waypoint s'affiche sous la forme d'un diamant bleu
 * sur la carte.
 * Il persiste tant qu'il n'est pas remplacé ou supprimé
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:azimut/model/geo_utils.dart';
import '../providers/location_provider.dart';
import '../providers/mission_provider.dart';
import '../app/waypoint_Dto.dart';
import 'latlong_input_widget.dart';
import 'pc_mgrs_input_widget.dart';

class WaypointInputScreen extends StatefulWidget {


  const WaypointInputScreen({super.key,});

  @override
  State<WaypointInputScreen> createState() => _WaypointInputScreenState();
}

enum CoordinateInputMode {
  mgrs,
  latLon,
}

class _WaypointInputScreenState extends State<WaypointInputScreen>{
  // Équipe concernée, récupère le nom en mode EM sinon demande le nom
  // en mode PC. Doit être déclarée au niveau du State, sinon elle est remise à
  // null à chaque build
  String? _equipeId;
  LatLng? _waypointEquipe;

  String _initialGzd = '';
  String _initialSquare = '';

  String? _mgrsEquipe;

  CoordinateInputMode _inputMode = CoordinateInputMode.mgrs;

  void _onPositionValidated(LatLng position) {
    setState(() {
      _waypointEquipe = position;
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

    // PC ou Equipe Mobile
    final isPc = mission.isPc;

    // equipesIds est une List<String>
    final equipesIds = mission.equipeIds;

    if( !isPc) {
      _equipeId ??= equipesIds.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion d\'un waypoint')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,20,16,30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 5),

            /******** SELECTION DE L'ÉQUIPE *********/
            /* pas activé pour l'instant en mode PC */

            Text("Nouveau waypoint pour : ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 5),

            if (isPc)
              DropdownButton<String>(
                value: _equipeId,
                hint: const Text('Sélectionner l\'équipe'),
                onChanged: (value) {
                  setState(() {
                    _equipeId = value;
                  });
                },
                items: equipesIds.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            else
              Text(
                equipesIds.first,
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 15),

            /******** SELECTION DU TYPE DE COORDONNEES**********/
            /********* MGRS ou LAT/LONG ************************/
            const Text(
              "Mode de saisie des coordonnées",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            SegmentedButton<CoordinateInputMode>(
              segments: const [
                ButtonSegment(
                  value: CoordinateInputMode.mgrs,
                  label: Text('MGRS'),
                ),
                ButtonSegment(
                  value: CoordinateInputMode.latLon,
                  label: Text('Lat / Lon'),
                ),
              ],
              selected: {_inputMode},
              onSelectionChanged: (selection) {
                setState(() {
                  _inputMode = selection.first;
                  _waypointEquipe = null; // reset sécurité
                });
              },
            ),

            /******** SAISIE DE LA POSITION DE L'ÉQUIPE *********/
            const Text(
              "Coordonnée du waypoint (MGRS 100m, 2x3 chiffres)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            /*** inital
                MGRSInput(
                onPositionValidated: _onPositionValidated,
                ),
             */
            _buildCoordinateInput(),


            /******** VALIDATION *********/
            Center(
              child: ElevatedButton(
                child: const Text("Valider le waypoint"),
                onPressed: () {
                  _onValiderWaypoint();
                },// onPressed
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateInput() {
    switch (_inputMode) {
      case CoordinateInputMode.mgrs:
        return  MGRSInput(
          initialGzd: _initialGzd,
          initialSquare: _initialSquare,
          onPositionValidated: (latLng) {
            setState(() {
              _waypointEquipe = latLng;
            });
          },
        );

      case CoordinateInputMode.latLon:
        return LatLonInput(
          onPositionValidated: (latLng) {
            setState(() {
              _waypointEquipe = latLng;
            });
          },
        );
    }
  }

  void _creerWaypointDTO(){
    final dto = WaypointDTO(
      equipeId: _equipeId,
      position: _waypointEquipe!,
    );
    debugPrint('🎯 Waypoint créé en $_waypointEquipe');
    Navigator.pop(
      context,
      dto,
    );
  }

  void _onValiderWaypoint() {
    if (_equipeId == null) {
      _showErreurEquipeNonSelectionnee();
      return;
    }
    if (_waypointEquipe == null){
      _showErreurPositionManquante();
      return;
    }

    _creerWaypointDTO();
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
  }

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
  }
}