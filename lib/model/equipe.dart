import 'tir.dart';

/* classe définissant un membre de l'équipe
 * j'ai supprimé la class membre pour l'instant. On verra si nécessaire
 * plus tard en passant de List<String> à List<Membre>
 */

/* class définissant une équipe: liste de membres
 * ainsi qu'une liste de tirs réalisés par l'équipe.
 * Tout est public. pas besoin de getter
 *
 * Une équipe peut être créée par
 * final equipe1 = Equipe (
 *      equipeId: "A",
 *      equipeName: "Diogène1",
 *      equipeMembres: ['F4JAM', 'F4CGD']
 *  );
 */

class Equipe {
  String             equipeId; // peut être mis à jour après contact PC
  final List<String> equipeMembres;  // callsigns
  final List<Tir>    equipeTirs;


  // constructor avec initialisation par défaut
  Equipe( {
    required this.equipeId,
    List<String>? equipeMembres,
    List<Tir>? equipeTirs
  }) : equipeMembres = equipeMembres ?? [],
       equipeTirs = equipeTirs ?? [];


  // ajoute un membre
  void addMembre(String membre) {
    equipeMembres.add(membre);
  }

  // ajoute un tir
  void addTir(Tir tir) {
    equipeTirs.add(tir);
  }

  // pour export JSON
  Map<String, dynamic> toJson() {
    return {
      'equipeId': equipeId,
      'membres': equipeMembres,
      'tirs': equipeTirs.map((t) => t.toJson()).toList(),
    };
  }

} // class Equipe