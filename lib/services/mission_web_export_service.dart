/* l'export d'un fichier au format JSON ne fonctionne que sur Android et IOS.
 * si on utilise l'app dans navigateur Chrome ou Edge, on peut pas créer un
 * fichier directement du navigateur vers le système. Il faut "télécharger" le
 * fichier
 */

// Ne doit être importé/compilé que sur Web.
// crée un fichier mission_YYYY-MM-DDTHH-MM-SS.json téléchargé par Chrome.
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../model/mission.dart';
import 'mission_export_service.dart';

class MissionWebExportService {
  /// Télécharge un JSON via le navigateur (Flutter Web).
  static void downloadJson(Mission mission) {

    final jsonString = MissionExportService.exportToJson(mission);
    // On met directement la string dans le Blob (pas besoin d'Uint8List)
    final parts = <web.BlobPart>[
      jsonString.toJS,
    ].toJS;

    final blob = web.Blob(
      parts,
      web.BlobPropertyBag(type: 'application/json'),
    );

    final url = web.URL.createObjectURL(blob);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filename = 'mission_$timestamp.json';

    final a = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    web.document.body?.append(a);
    a.click();
    a.remove();

    web.URL.revokeObjectURL(url);
  }
}
