import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';

/* Fenêtre de saisie d'une nouvelle équipe par le PC
 * Activée quand le PC appuie sur le bouton "Nouvelle équipe" depuis la carte.
 * La fenêtre affiche les équipes déjà existantes et propose l'ID suivant
 * sur le modèle DIOGENEx
 */

class PcEquipeInputScreen extends StatelessWidget {

  const PcEquipeInputScreen({super.key,});

  @override
  Widget build(BuildContext context) {

    final missionProvider = context.watch<MissionProvider>();

    // récupère les Id's des équipes existantes
    //List <String> equipesExistantes = missionProvider.equipeIds;
    final equipesExistantes = missionProvider.equipes.map((e) => e.equipeId).toList();

    // récupère la suggestion pour le nouvel ID
    final newId = missionProvider.suggestNextEquipeId();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle équipe')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,20,16,30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Equipes existantes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (equipesExistantes.isEmpty)
              const Text('Aucune équipe créée')
            else
              Wrap(
                spacing: 8,
                children: equipesExistantes
                    .map((id) => Chip(label: Text(id)))
                    .toList(),
              ),

            const Divider(height: 32),
            Text("Créer l'équipe ?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                newId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    missionProvider.createEquipe(newId);
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}