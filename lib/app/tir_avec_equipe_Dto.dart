import '../model/tir.dart';


/* DTO : Data Transfer Object
 * Objet créé pour pouvoir transmettre l'ID d'une equipe (son nom, String)
 * avec la liste des tirs qu'elle a réalisés
 * un Tir "ne sait pas" par qui il a été fait, la liste des tirs appartient à
 * l'équipe.
 * un getter de cet objet est ajouté à MissionProvider
 * l'info est utilisée dans AfficheTirs
 */
class TirAvecEquipe {
  final Tir tir;
  final String nomEquipe;

  TirAvecEquipe({
    required this.tir,
    required this.nomEquipe,
  });
}
