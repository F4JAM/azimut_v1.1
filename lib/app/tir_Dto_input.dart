import 'package:latlong2/latlong.dart';
import '../app/signal_strength.dart';

/* Data Transfer Object : object servant à ramener les données
 * saisies lors d'un nouveau tir.
 * Pour le PC il faut ramener l'ID et les coordonnées de l'équipe mobile
 * en plus de l'azimut et la force du signal.
 *  * Pour une équipe mobile, son ID et sa position sera donnée par
 * la mission (une seule équipe) et LocationProvider plus
 * tard. D'où les String? et  LatLng? : peuvent être null
 */

class TirInputDTO {
  final String? equipeId; // peut être null en mode EM
  final LatLng? position; // peut être null pour une équipe mobile
  final double azimut;
  final Strength forceSignal;  // enum défini dans signal_strength.dart

  TirInputDTO({
    this.equipeId, // pas obligatoire en mode EM
    this.position, // pas obligatoire
    required this.azimut,
    required this.forceSignal,
  });
}