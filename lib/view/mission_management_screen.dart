import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';
import '../services/mission_file_export_service.dart';
import 'package:share_plus/share_plus.dart';

import '../services/mission_exporter_factory.dart';


class MissionManagementScreen extends StatelessWidget {
  const MissionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de la mission'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Exporter la mission'),

              onPressed: () async {
                final mission = context.read<MissionProvider>().mission;

                await exporter.export(mission);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export OK')),
                );
              },

              /* à restaurer si ça plante :)
              onPressed: () async {
                final mission = context.read<MissionProvider>().mission;
                final file = await MissionFileExportService.exportMissionToFile(mission);

                await Share.shareXFiles([XFile(file.path)], text: 'Export mission JSON');

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export + partage OK')),
                );
              },// onPressed
              */
            ),

            const SizedBox(height: 12),

            /* bouton non retenu pour l'instant ***
            ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle),
              label: const Text('Terminer la mission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: ()  {},
            ), */
          ],
        ),
      ),
    );
  }
}