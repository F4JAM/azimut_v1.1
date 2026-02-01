import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';
import '../model_view/mission_map.dart';

class MissionHomeScreen extends StatelessWidget {
  const MissionHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final missionProvider = context.watch<MissionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          missionProvider.isPc
              ? 'PC'
              : 'Équipe ${missionProvider.mission.equipes.first.equipeId}',
        ),
      ),
      body: const MissionMap(), // ta carte
    );
  }
}