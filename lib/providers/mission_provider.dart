import 'package:flutter/material.dart';
import 'package:azimut/model/waypoint.dart';
import '../model/mission.dart';
import '../model/equipe.dart';
import '../app/app_role.dart';
import '../model/tir.dart';
import '../app/tir_Dto_input.dart';
import '../app/equipe_Dto_input.dart';
import '../app/tir_avec_equipe_Dto.dart';
import '../app/waypoint_Dto.dart';
import 'location_provider.dart';
import '../services/mission_storage_service.dart'; //Hive

class MissionProvider extends ChangeNotifier {
  final AppRole role;
  final Mission mission;

  late LocationProvider _location;

  // constructeur privé, ne peut être utilisé que dans la class
  MissionProvider._(this.role, this.mission);

  /* constructor spécial de MissionProvider
   * en fonction du rôle transmis , crée une mission type PC
   * ou un de type équipe mobile (Mission aura deux constructors)
   */
  factory MissionProvider.bootstrap(AppRole role, {String? equipeId}) {
    if (role == AppRole.equipeMobile) {
      // Si aucun ID fourni, on génère un ID temporaire unique sur le nombre de
      // secondes Epoch, converti en base36 (0-9, a-z)
      final id = equipeId ??
       '${(DateTime.now().millisecondsSinceEpoch ~/ 1000).toRadixString(36)}';
      return MissionProvider._(
        role,
        Mission.createEquipeMobile(equipeId: id),
      );
    } else {
      return MissionProvider._(
        role,
        Mission.createPC(),
      );
    }
  }

  // constructeur pour restauration Hive
  factory MissionProvider.restored(AppRole role, Mission mission) {
    return MissionProvider._(role, mission);
  }

  /// Constructeur nommé pour restaurer une mission existante
  factory MissionProvider.restore(AppRole role, Mission missionToRestore) {
    return MissionProvider._(role, missionToRestore);
  }


  // une map equipeId - Waypoint
  final Map<String, Waypoint> _activeWaypointsByEquipe = {};

  bool get isPc => role == AppRole.pc;

  // Permet de mettre à jour l'ID de l'équipe mobile après réception du vrai ID
  void setEquipeId(String newId) {
    if (role == AppRole.equipeMobile && mission.equipes.isNotEmpty) {
      mission.equipes[0].equipeId = newId;
      notifyListeners();
    }
  }

  /* récupère dans une liste les tirs réalisés en fonction du rôle :
   * soit les tirs de toutes les équipes si on est le PC, soit les tirs de
   * l'équipe si on est une équipe mobile.
   * utilisé dans MissionMap
   */
  List<Tir> get visibleTirs {
    if (isPc) {
      // PC : tous les tirs de toutes les équipes
      return mission.equipes
          .expand((e) => e.equipeTirs)
          .toList();
    } else {
      // Équipe mobile : uniquement ses tirs
      if (mission.equipes.isEmpty) return [];
      return mission.equipes.first.equipeTirs;
    }
  }

  // essai création d'une map : equipeId , tirs
  Map<String, List<Tir>> equipeIdToTirs() {
    return Map.fromEntries (
    mission.equipes.map( (equipe) => MapEntry(equipe.equipeId, equipe.equipeTirs))
    );
  }

 // getter pour récupérer au niveau de la mission une liste de Tirs
 // avec le nom de l'équipe associé. Utilise le DTO TirAvecEquipe
 // pour pouvoir afficher le nm de l'équipe dans AfficheTir
 // liste triée par équipe puis pas tirs de l'équipe.
 List<TirAvecEquipe> get visibleTirsAvecEquipe {
    if(isPc) {
      return mission.equipes.expand( (equipe) {
        return equipe.equipeTirs.map( (tir) {
          return TirAvecEquipe(
              tir: tir,
              nomEquipe: equipe.equipeId,
          );
        });
      }).toList();
    } else {
      if(mission.equipes.isEmpty) return[];
      final equipe = mission.equipes.first;
      return equipe.equipeTirs.map( (tir) {
        return TirAvecEquipe(
          tir: tir,
          nomEquipe: equipe.equipeId,
      );
    }).toList();
  }
} // get visibleTirsAvecEquipe

// getter pour récupérer au niveau de la mission une liste de Tirs
  // avec le nom de l'équipe associé. Utilise le DTO TirAvecEquipe
  // pour pouvoir afficher le nm de l'équipe dans AfficheTir
  // liste triée par ordre chronologique des tirs
  List<TirAvecEquipe> get visibleTirsAvecEquipeChrono {
    final List<TirAvecEquipe> result =[];
    for (final equipe in mission.equipes) {
      for (final tir in equipe.equipeTirs) {
        result.add(
          TirAvecEquipe(
              tir: tir,
              nomEquipe: equipe.equipeId
          ),
        );
      }
    }

    result.sort( (a,b) => a.tir.timestamp.compareTo(b.tir.timestamp));

    return result;
  } // get visibleTirsAvecEquipeChrono


  // getter pour récupérer les équipes
  List<Equipe> get equipes => mission.equipes;

  /* Récupère l'objet Equipe à partir de son ID.
   * Normalement pas d'erreur possible : le PC aura sélectionné l'ID
   * il ne l'aura pas saisi
   */
  Equipe getEquipeById(String equipeId) {
    return mission.equipes.firstWhere(
          (e) => e.equipeId == equipeId,
      orElse: () => throw StateError('Équipe $equipeId introuvable'),
    );
  }

  /* Récupère l'index de l'équipe dans la liste des équipes de la mission
   * à partir de son ID.
   * Normalement pas d'erreur possible : le PC aura sélectionné l'ID
   * il ne l'aura pas saisi
   */
  int getEquipeIndexById(String equipeId) {
    return mission.equipes.indexWhere((e) => e.equipeId == equipeId);
  }

  // pour récupérer les ID's des équipes (pour la saisie d'un tir notamment)
  List<String> get equipeIds =>
      mission.equipes.map((e) => e.equipeId).toList();


  // Propose l'ID d'une nouvelle équipe. Les ID sont basés sur le modèle
  // Diogene[x], où x = 1, 2, 3 etc... Si une nouvelle équipe se signale
  // elle prendra l'ID suivant dans la liste ... Diogene[n+1] !
  // Attention : ne gère pas les "trous" : suppression d'une équipe
  String suggestNextEquipeId() {
    int nbEquipe = mission.equipes.length;
    return ("DIOGENE${nbEquipe+1}");
  }


  /* Ajoute une équipe par le PC via un DTO
   *required this.equipeId, // pas obligatoire en mode EM
   *this.position, // pas obligatoire
   *
   */
  void addEquipeFromInput(EquipeDtoInput dto) {
    Equipe nouvelleEquipe = Equipe(equipeId: dto.equipeId);
    mission.equipes.add(nouvelleEquipe);

    // sauvegarde Hive
    MissionStorageService.save(mission);

    notifyListeners();
  }

  // en mode Equipe mobile, renomme l'équipe
  void renameEquipeFromInput(String id) {
    mission.equipes.first.equipeId = id;

    // Sauvegarde Hive
    MissionStorageService.save(mission);

    notifyListeners();
  }

  void createEquipe(String id) {
    Equipe nouvelleEquipe = Equipe(equipeId: id);
    mission.equipes.add(nouvelleEquipe);

    // sauvegarde Hive
    MissionStorageService.save(mission);

    notifyListeners();
  }

  void setLocationProvider(LocationProvider location) {
    _location = location;
  }

  void addTirFromInput(TirInputDTO dto) {
    // si on est PC : la position vient du DTO, sinon elle vient de LocationProvider
    final position = isPc
        ? dto.position!
        : _location.currentLocation!;

    // construire Tir ici
    Tir nouveauTir = Tir(position: position, heading: dto.azimut, strength: dto.forceSignal);

    /* ajout du tir à l'équipe concernée :
     * dans le cas d'une EM : c'est la seule de la mission [0]
     * dans le cas d'une PC : l'ID de l'équipe est fourni via le DTO
     */
    // sélection de l'équipe : via PC ou EM
    int  indexEquipeTireuse = isPc ? getEquipeIndexById(dto.equipeId!) : 0;

    mission.equipes[indexEquipeTireuse].addTir(nouveauTir);
    print("nouveau tir ajouté");

    // sauvegarde automatique par Hive
    MissionStorageService.save(mission);

    notifyListeners();

  } //addTirFromInput

  /*******************************
   * GESTION DES WAYPOINTS
   *******************************/

  // En mode EM : Test si un waypoint a été affecté à l'équipe (la seule)
  bool hasWaypoint(){
    return _activeWaypointsByEquipe.containsKey(mission.equipes.first.equipeId);
  }

  // En mode EM : récupère le waypoint, s'il existe
  Waypoint? getWaypoint() {
    return _activeWaypointsByEquipe[mission.equipes.first.equipeId];
  }

  // En mode EM : ajoute/remplace un waypoint
  void addWayPointFromInput(WaypointDTO dto) {
    final equipeId = dto.equipeId ?? mission.equipes.first.equipeId;

    // construire waypoint ici
    final waypoint = Waypoint(position: dto.position ,equipeId: equipeId);

    // ajout du waypoint à la map :
    _activeWaypointsByEquipe[equipeId] = waypoint;

    notifyListeners();

  } //addWaypointFromInput

  // En mode EM : Supprimer un waypoint
  void clearWaypoint() {
    _activeWaypointsByEquipe.remove(mission.equipes.first.equipeId);
    notifyListeners();
  }

  // En mode EM Getter du waypoint pour MissionMap notamment
  Waypoint? get activeWaypoint{
    if( !isPc && mission.equipes.isNotEmpty) {
      return _activeWaypointsByEquipe[mission.equipes.first.equipeId];
    }
    return null;
  }

  /* Pour développement futur : gestion des waypoints en mode PC
   * bool hasWaypointForEquipe(String equipeId)
   * Waypoint? getWaypointForEquipe(String equipeId)
   */

} // class MissionProvider