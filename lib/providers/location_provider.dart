/* utilise Provider.
 * Gère la position courante, écoute le stream fourni par location_service
  * Gère l'état de synchro GPS ou envoie une erreur
  * Diffuse l'état de synchro GPS et diffuse le stream de positions GPS
 * oloobo 2025_12_11
 */

/* on peut également ajouter :
  un heading (boussole)
  une vitesse
  une altitude
  un état "en mission / pause / fin"
  etc.
 */

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  // les properties de la class
  LatLng? _currentLocation;
  String? _error;
  bool _isGPSLoading = true; // synchro GPS en cours

  // les getters
  LatLng? get currentLocation => _currentLocation;
  String? get error => _error;
  bool get isGPSLoading => _isGPSLoading;

  // le constructor qui appelle _init()
  LocationProvider() {
    _init();
  }

  // à la construction du LocationProvider
  Future<void> _init() async {
    try {
      // Diffuse que le GPS est en cours de synchro
      _isGPSLoading = true;
      notifyListeners();

      // Récupère la position initiale
      _currentLocation = await LocationService.instance.determinePosition();

      // Récupère et diffuse le Stream GPS en continu
      LocationService.instance.getPositionStream().listen((latLng) {
        _currentLocation = latLng;
        notifyListeners();
      });

    } catch (e) {
      _error = e.toString();
    }
    // Diffuse que le GPS est synchronisé
    _isGPSLoading = false;
    notifyListeners();
  }
}