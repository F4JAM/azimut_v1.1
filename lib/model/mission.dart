import '../model/equipe.dart';
import '../app/app_role.dart';



class Mission {
  final AppRole role;
  final List<Equipe> equipes;

  Mission._({
    required this.role,
    required this.equipes,
  });

  /* une équipe est constituée de :
  final String       equipeId; fourni par le PC
  final List<String> equipeMembres;  // callsigns
  final List<Tir>    equipeTirs;
   */

  /// Pour une équipe mobile : ID obligatoire
  factory Mission.createEquipeMobile({required String equipeId}) {
    return Mission._(
      role : AppRole.equipeMobile,
      equipes : [
        Equipe(
        equipeId: equipeId,
        equipeMembres: [],
        equipeTirs: [],
      ),
    ]);
  }

  /// Pour le PC : liste vide d'équipes
  factory Mission.createPC() {
    return Mission._(
        role: AppRole.pc,
        equipes: <Equipe>[]);
  }

  /// Constructeur utilisé pour la restauration Hive
  factory Mission.fromHive({
      required AppRole role,
      required List<Equipe> equipes,
  }) {
      return Mission._(
        role: role,
        equipes: equipes
      );
     }

  // pour export JSON
  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'equipes': equipes.map((e) => e.toJson()).toList(),
    };
  }
}
