import 'package:provider/provider.dart';
import 'package:azimut/app/waypoint_Dto.dart';
import '../providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import '../providers/mission_provider.dart';
import '../model_view/mobile_tir_input_screen.dart';
import '../model_view/pc_tir_input_screen.dart';
import '../model_view/pc_equipe_input_screen.dart';
import '../model/geo_utils.dart';
import '../model_view/affiche_tirs.dart';
import 'rename_equipe_input_screen.dart';
import 'waypoint_input_screen.dart';
import '../view/mission_management_screen.dart';

enum _WaypointAction { edit, delete }

class MissionMap extends StatefulWidget {
  const MissionMap( {super.key});
  @override
  State<MissionMap> createState() => MissionMapState();
}

class MissionMapState extends State<MissionMap> {
  final MapController _mapController = MapController();

  @override
  // Ecoute des providers par le build : le GPS et la mission
  Widget build(BuildContext context) {
    final location        = context.watch<LocationProvider>();
    final  mission        = context.watch<MissionProvider>();
    final missionProvider = context.watch<MissionProvider>();
    /* à chaque ajout d'un tir dans mission_provider, le notifyListeners()
     * va déclencher un build du widget mission_map pour mettre à jour les
     * markers   */
    // récupère tous les tirs dans une liste (PC ou équipe mobile)
    final tirs = missionProvider.visibleTirs;
    final isPc = context.watch<MissionProvider>().isPc;
    final waypoint = context.watch<MissionProvider>().activeWaypoint;

    if (waypoint != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          waypoint.position,
          _mapController.camera.zoom,
        );
      });
    }

    // utilisation de location_provider
    if (location.isGPSLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (location.error != null) {
      return Center(child: Text('Erreur GPS: ${location.error}'));
    }

    final LatLng? current = location.currentLocation;
    // fin de l'utilisation de location_provider

    // construction des markers et des polylines
    //final waypoint = context.watch<MissionProvider>().activeWaypoint;
    final waypointMarkers = <Marker>[];
    if(waypoint !=null) {
      waypointMarkers.add(
        Marker(
          point: waypoint.position,
          width: 30,
          height: 30,
          child: const Icon(
            Icons.diamond,
            color: Colors.blueAccent,
            size: 30,
          ),
        ),
      );
    }

    final markersTirs = tirs.map((tir) {
      return Marker(
          point: tir.position,
          width: 30,
          height: 30,
          child: const Icon(
              Icons.gps_fixed,
              color: Colors.red,
              size: 20
          )
      );
    }).toList();

    final polylines = tirs.map((tir) {
      return Polyline(
        points: tir.line,
        strokeWidth: 2,
        color: Colors.red,
      );
    }).toList();
// fin de construction des markers et des polylines

/*
 * quand on appuie sur nouveau tir, en fonction du rôle fourni par
 * MissionProvider, on active un widget de saisie du tir
*/
    Future<void> _onNewTirPressed (BuildContext context) async {
      // on récupère les infos de la mission
      final mission = context.read<MissionProvider>();

      // accède aux pages en fonction du rôle
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => mission.isPc
              ?  const PcTirInputScreen()
              :  const MobileTirInputScreen()
              /// nota : si on utilise builder(context) on redéclare une nouvelle
              /// variable context qui masque le contexte de la méthode
              /// _onNewTirPressed. On n'a pas besoin d'un nouveau context : "_"
        ),
      ); // retour du push

      if (result != null) {
        mission.addTirFromInput(result); // envoie du DTO tirInput
      }

    } //  _onNewTirPressed

 /*
 * quand on appuie sur Affiche les tirs on active un widget qui affiche
 * tous les tirs de l'équipe ou de toutes les équipes
 */
    Future<void> _onAfficheTirs (BuildContext context) async {
      final mission = context.read<MissionProvider>();
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AfficheTirs(),
          ),
      );
    } // _onAfficheTirs

/*
 * On mode PC uniquement : bouton "Nouvelle équipe"
 * on active un widget de saisie de l'équipe
*/
    Future<void> _onNewEquipePressed (BuildContext context) async {
      // on récupère les infos de la mission
      final mission = context.read<MissionProvider>();

      // accède aux pages en fonction du rôle
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const PcEquipeInputScreen()

          /// nota : si on utilise builder(context) on redéclare une nouvelle
          /// variable context qui masque le contexte de la méthode
          /// _onNewTirPressed. On n'a pas besoin d'un nouveau context : "_"
        ),
      ); // retour du push

      if (result != null) {
        mission.addEquipeFromInput(result); // envoie du DTO tirInput
      }
    } // _onNewEquipePressed

    /*
 * On mode Equipe mobile uniquement : bouton "Modifier le nom de l'équipe"
 * on active un widget de saisie dun nouveau nom pour l'équipe
*/
    Future<void> _onRenameEquipePressed (BuildContext context) async {
      // on récupère les infos de la mission
      final mission = context.read<MissionProvider>();

      // accède aux pages en fonction du rôle
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const RenameEquipeInputScreen()

          /// nota : si on utilise builder(context) on redéclare une nouvelle
          /// variable context qui masque le contexte de la méthode
          /// _onNewTirPressed. On n'a pas besoin d'un nouveau context : "_"
        ),
      ); // retour du push

      if (result != null) {
        mission.renameEquipeFromInput(result); // envoie du DTO tirInput
      }
    } // _onRenameEquipePressed


  /* en mode Equipe Mobile, affiche un écran permettant de créer, modifier ou
   * supprimer un waypoint
   */
    Future<void> _onWaypointPressed (BuildContext context) async {
      final mission = context.read<MissionProvider>();

      //si on n'avait pas déjà un WP attribué
      if(!mission.hasWaypoint()) {
        final dto = await Navigator.push<WaypointDTO>(
          context,
          MaterialPageRoute(
            builder: (_) => WaypointInputScreen(),
          ),
        );

        if(dto != null) {
          mission.addWayPointFromInput(dto);
      }
      return;
      } // si pas de WP

      // si un WP existe déjà affiche le choix : suppr ou edit
      final action = await showDialog<_WaypointAction>(
          context: context,
          builder: (_) => const _WaypointActionDialog(),
      );

      if (action == _WaypointAction.delete) {
        mission.clearWaypoint();
        return;
      }
      if(action == _WaypointAction.edit) {
        final dto = await Navigator.push<WaypointDTO>(
          context,
          MaterialPageRoute(
            builder: (_) => const WaypointInputScreen(),
          ),
        );
        if(dto != null) {
          mission.addWayPointFromInput(dto);
        }
      }
    } //  _onWaypointPressed

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: current ?? const LatLng(78.2, 15.5),
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              urlTemplate:
              'https://data.geopf.fr/wmts'
                  '?service=WMTS'
                  '&request=GetTile'
                  '&version=1.0.0'
                  '&layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2'
                  '&style=normal'
                  '&tilematrixset=PM'
                  '&tilematrix={z}'
                  '&tilerow={y}'
                  '&tilecol={x}'
                  '&format=image/png',
              userAgentPackageName: 'fr.olooboo.app',
            ),

            // la position courante est gérée par flutter_map_location_marker
            CurrentLocationLayer(),

            MarkerLayer(markers: markersTirs),
            MarkerLayer(markers: waypointMarkers),
            PolylineLayer(polylines: polylines),
          ],
        ),

        // affiche la position courante & MGRS, en haut, au centre
        Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Text(
                '${current?.latitude}, ${current?.longitude} \n ${current?.toMGRSString()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.yellowAccent,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              if (current != null) {
                _mapController.move(current, 15);
              }
            },
            tooltip: 'Vous êtes ici !',
            child: const Icon(Icons.my_location),
          ),
        ),
/*****************************************/
        // Bouton: nouveau tir
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            onPressed: () {
              _onNewTirPressed(context);
            },
            tooltip: 'Nouveau Tir',
            child: Icon(Icons.explore_rounded, color: Colors.red),
          ),
        ),

/********************************************/
        // Bouton: affiche la liste des tirs
        Positioned(
          bottom: 108,
          left: 16,
          child: FloatingActionButton(
            onPressed: () {
              _onAfficheTirs(context);
            },
            tooltip: 'Affiche les tirs',
            child: Icon(Icons.event_note, color: Colors.green),
          ),
        ),
/***************************************** */
       // Bouton : nouvelle équipe, en mode PC uniquement :
       // une équipe se signale, on va la créer avec un Id
       // En mode équipe mobile : modifie le nom de l'équipe
      if (isPc)
        Positioned(
            top:  16,
            left: 16,
            child: FloatingActionButton(
                onPressed: (){
                  _onNewEquipePressed(context);
                },
                tooltip: 'Ajouter une nouvelle équipe',
                child: const Icon(Icons.group_add),
            )
        ),
        if (!isPc)
          Positioned(
              top:  16,
              left: 16,
              child: FloatingActionButton(
                onPressed: (){
                  _onRenameEquipePressed(context);
                },
                tooltip: 'Modifier le nom de l\'équipe',
                child: const Icon(Icons.assignment_ind_outlined),
              )
          ),

/********************************************/
        // Bouton: saisie d'un waypoint, en mode EM uniquement :
        if (!isPc)
          Positioned(
            bottom: 108,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                _onWaypointPressed(context);
              },
              tooltip: 'Saisir un waypoint',
              child: Text("WP"),
            ),
          ),
        /***************************************** */

/********************************************/
        // Bouton: gestion de mission :

        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MissionManagementScreen(),
                ),
              );
            },
            tooltip: 'Gestion de la mission',
            child: Icon(Icons.event_note, color: Colors.green),
          ),
        ),
        /***************************************** */

        SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
          backgroundColor: Colors.transparent,
          alignment: Alignment(0, 1),
        ),
      ],
    );
  }
}

class _WaypointActionDialog extends StatelessWidget {
  const _WaypointActionDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Waypoint existant'),
      content: const Text('Que voulez-vous faire ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _WaypointAction.edit),
          child: const Text('Modifier'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _WaypointAction.delete),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}