import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';
import '../app/equipe_Dto_input.dart';

class RenameEquipeInputScreen extends StatelessWidget {

  const RenameEquipeInputScreen({super.key,});

  @override
  Widget build(BuildContext context) {
    final missionProvider = context.watch<MissionProvider>();
    final TextEditingController _idController = TextEditingController();

    // récupère l'Id de l'équipe
    //List <String> equipesExistantes = missionProvider.equipeIds;
    final nomEquipeExistant = missionProvider.equipes.first.equipeId;

    // récupère la suggestion pour le nouvel ID
    final newId = "toto";

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le nom de l\'équipe')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nom actuel :",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              nomEquipeExistant,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Nouveau nom :',
                hintText: 'ex : Diogène1',
              ),
            ),

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
                    missionProvider.renameEquipeFromInput(_idController.text.trim());
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