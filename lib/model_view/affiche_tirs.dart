import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:azimut/model/geo_utils.dart';
import '../providers/mission_provider.dart';
import '../app/signal_strength.dart';

/* Fenêtre d'affichage de tous les tirs
 * pour le PC : affiche tous les tirs de toutes les équipes
 * pour une équipe mobile : affiche uniquement ses tirs
 */

class AfficheTirs extends StatelessWidget {

  const AfficheTirs({super.key,});

  @override
  Widget build(BuildContext context) {
    final missionProvider = context.watch<MissionProvider>();

    // récupère les tirs (tous ou ceux de l'équipe)
    //final tirs = missionProvider.visibleTirs;
    //final tirs = missionProvider.visibleTirsAvecEquipe;
    final tirs = missionProvider.visibleTirsAvecEquipeChrono;

    final equipetirs = missionProvider.equipeIdToTirs();
    debugPrint ("$equipetirs");

    // pour afficher un texte plutôt que l'enum
    final Map<Strength, String> strengthLabels = {
      Strength.Tres_faible: "Très faible",
      Strength.Faible: "Faible",
      Strength.Moyen: "Moyen",
      Strength.Fort: "Fort",
      Strength.Tres_fort: "Très fort",
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Tirs'),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
      ),
      body: ListView.builder(
        itemCount: tirs.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final tirAvecEquipe = tirs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            elevation: 2,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tir ${index + 1} cliqué'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tir ${index + 1}, Équipe: ${tirAvecEquipe.nomEquipe}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.gps_fixed, color: Colors.blue),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text('📅 ${_formatDate(tirAvecEquipe.tir.timestamp)}',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),

                  // avec des badges
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _coordBadge(
                        icon: Icons.grid_4x4,
                        label:'MGRS: ${tirAvecEquipe.tir.position.toMGRSString()}',
                      ),

                      const SizedBox(height: 5),

                      _coordBadge(
                        icon: Icons.my_location,
                        label:'Lat/Lon: '
                        '${tirAvecEquipe.tir.position.latitude.toStringAsFixed(4)}, '
                            '${tirAvecEquipe.tir.position.longitude.toStringAsFixed(4)}',
                      ),
                    ],
                  ),
                   Text('🧭 Azimut: ${tirAvecEquipe.tir.heading.toStringAsFixed(1)}°',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    //Text('💪 Force: ${tir.strength}',
                      Text('💪 Force: ${strengthLabels[tirAvecEquipe.tir.strength]}',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

Widget _coordBadge({
  required IconData icon,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha:0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}