/* localisation service : sortie de la logique d'initialisation et
 * utilisation du GPS de la logique de gestion de la carte OSM. Voir en bas
 * comment utiliser le service dans mission_map.dart
 * oloobo  2025_12_11
 */

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50,
  );

  /// Vérifie GPS + permission, puis retourne la position initiale.
  Future<LatLng> determinePosition() async {
    // 1. GPS activé ?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Le GPS n’est pas activé');
    }

    // 2. Permission ?
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission GPS refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception("Permission GPS refusée définitivement");
    }

    // 3. Obtenir la position
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    );

    return LatLng(pos.latitude, pos.longitude);
  }

  /// Stream de positions en temps réel
  Stream<LatLng> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings)
        .map((pos) => LatLng(pos.latitude, pos.longitude));
  }
}


/* MODIFICATION A FAIRE DANS mission_map.dart
//1) Importer le service : OK
      import '../services/location_service.dart';
//2) Modifier l'initState()
      @override
      void initState() {
        super.initState();

       // Récupérer la position initiale
        LocationService.instance.determinePosition().then((latLng) {
        setState(() {
            _currentLocation = latLng;
         });
        _mapController.move(latLng, 15);
        });

      // Écouter la position en temps réel
      LocationService.instance.getPositionStream().listen((latLng) {
        setState(() => _currentLocation = latLng);
        });
      }
//3) _userCurrentLocation() reste identique
//4)  supprimer toute la gestion d'autorisation
toute la gestion d’autorisation
     _determinePosition
    _getLocation
    _positionStream
    locationSettings
 */