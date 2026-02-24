/* App Azimut : aide à la recherche de balise radio
 * F4JAM - 2026
 * Licence MIT
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/location_provider.dart';
import 'package:azimut/providers/mission_provider.dart';
import 'package:azimut/view/mission_home_screen.dart';
import 'app/app_role.dart';
import 'model/mission.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/model/hive/strength_adapter.dart'; //  pour Hive avec l'enum Strength
import 'model/hive/latlng_adapter.dart'; // pour Hive avec les LatLng
import 'model/hive/tir_adapter.dart'; // pour Hive avec les Tirs
import 'model/hive/equipe_adapter.dart'; // pour Hive avec les équipes
import 'model/hive/mission_adapter.dart'; // pour Hive avec la mission
import 'services/mission_storage_service.dart';

/* avant tout on lance le Bootstrap. On est dans runApp pour
pouvoir avoir une UI , mais avant que l'app "métier" ne démarre.
*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // appel aux adapters pour Hive
  Hive.registerAdapter(StrengthAdapter());
  Hive.registerAdapter(LatLngAdapter());
  Hive.registerAdapter(TirAdapter());
  Hive.registerAdapter(EquipeAdapter());
  Hive.registerAdapter(MissionAdapter());

  final missionRestored = await MissionStorageService.restore();

  runApp(BootstrapApp(
    restoredMission: missionRestored,
   )
 );
}

// le bootstrap qui envoie vers une page RoleSelectionScreen
class BootstrapApp extends StatelessWidget {

  final Mission? restoredMission;

  const BootstrapApp({super.key, this.restoredMission});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Initialisation de la mission',
      home : StartupScreen(restoredMission: restoredMission,),

      //home: restoredMission != null
      //  ? MissionApp(
      //        role:restoredMission!.role,
      //        restoredMission: restoredMission,
      //  )
      //  :const RoleSelectionScreen(),
      //RoleSelectionScreen(restoredMission: restoredMission),
    );
  }
}
/// ***************************
/// Page de sélection du role *
///***************************

class RoleSelectionScreen extends StatefulWidget {
  final Mission? restoredMission;
  final AppRole? restoredRole;

  const RoleSelectionScreen({
    super.key,
    this.restoredMission,
    this.restoredRole,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {

  // pour tester l'existence d'une mission sauvegardée (Hive)
  bool _hasExistingMission = false;

 // nouvelle mission ou mission sauvegardée
 Mission? _missionToUse;

  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _hasExistingMission = widget.restoredMission != null;

    if(widget.restoredMission != null && widget.restoredRole !=null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(widget.restoredRole == AppRole.pc){
          _startPc(context);
        } else {
          _startMobile(context);
        }
      }); //binding
    }
  } // initState

  void _startPc(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MissionApp(
            role: AppRole.pc,
            restoredMission: _missionToUse,
        ),
      ),
    );
  }

  void _startMobile(BuildContext context) {
    // récupère l'Id de l'équipe si restauration, sinon controller
    final id = widget.restoredMission != null
      ? widget.restoredMission!.equipes.first.equipeId
      : _idController.text.trim();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MissionApp(
          role: AppRole.equipeMobile,
          equipeId: id.isEmpty ? null : id, // null → ID temporaire auto
          restoredMission: _missionToUse,
        ),
      ),
    );
  }

  // dialogue si on veut restaurer ou commencer une nouvelle mission
  void _showRestoreDialog(BuildContext context) {
    _hasExistingMission = false; // évite la répétition

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Mission existante détectée'),
        content: const Text(
          'Une mission précédente est disponible.\n'
              'Souhaitez-vous la restaurer ou démarrer une nouvelle mission ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _missionToUse = widget.restoredMission;
              Navigator.pop(context);
            },
            child: const Text('Restaurer'),
          ),

          TextButton(
            onPressed: () async {
              await MissionStorageService.clear();
              _missionToUse = null;
              Navigator.pop(context);
            },
            child: const Text('Nouvelle mission'),
          ),
        ],
      ),
    );
  } //_showRestoreDialog

  @override
  Widget build(BuildContext context) {

    if (_hasExistingMission) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRestoreDialog(context);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Démarrer la recherche')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _startPc(context),
              child: const Text('En tant que Poste de Contrôle'),
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () => _startMobile(context),
              child: const Text('En tant qu’équipe mobile'),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID de l\'équipe (optionnel)',
                hintText: 'ex : Diogène1',
              ),
            ),
          ],
        ),
      ),
    );
  }
}  //_RoleSelectionScreenState

/// Produit un ChangeNotifierProvider et bascule sur la page MissionHomeScreen

class MissionApp extends StatelessWidget {
  final AppRole role;
  final String? equipeId;
  final Mission? restoredMission;

  const MissionApp({
    super.key,
    required this.role,
    this.equipeId,
    this.restoredMission,
  });

  @override
  Widget build(BuildContext context) {

    final AppRole effectiveRole =
        restoredMission?.role ?? role;

    return MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),

        ChangeNotifierProxyProvider<LocationProvider, MissionProvider>(
        create: (_) => restoredMission != null
          ? MissionProvider.restore(role, restoredMission!)
          : MissionProvider.bootstrap(role, equipeId: equipeId),

          update: (_, location, mission) {
            mission!.setLocationProvider(location);
            return mission;
          },
        ),
/*
        ChangeNotifierProxyProvider<LocationProvider, MissionProvider>(
          create: (_) => MissionProvider.bootstrap(
            role,
            equipeId: equipeId,
          ),
          update: (_, location, mission) {
            mission!.setLocationProvider(location);
            return mission;
          },
        ),
*/
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recherche',
        home: const MissionHomeScreen(),
      ),
    );
  }
}

/// Wrapper pour sauvegarder le role dans Hive (PC ou Equipe Mobile)
@HiveType(typeId: 5)
class SavedMission {
  @HiveField(0)
  final Mission mission;

  @HiveField(1)
  final AppRole role;

  SavedMission({required this.mission, required this.role});
}

/// écran de démarrage : choix de continuer une mission ou d'en lancer une
class StartupScreen extends StatefulWidget {
  final Mission? restoredMission;

  const StartupScreen({super.key, this.restoredMission});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  Mission? _missionToUse;

  void _decideNavigation() {
    if (!mounted) return;

    if (widget.restoredMission != null) {
      _showRestoreDialog();
    } else {
      _goToRoleSelection();
    }
  }


  @override
  void initState() {
    super.initState();

    Future.microtask(_decideNavigation);
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Mission existante'),
        content: const Text(
          'Une mission sauvegardée a été trouvée.\nQue souhaitez-vous faire ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _missionToUse = null;
              Navigator.pop(context);
              _goToRoleSelection();
            },
            child: const Text('Nouvelle mission'),
          ),
          ElevatedButton(
            onPressed: () {
              _missionToUse = widget.restoredMission;
              Navigator.pop(context);
              _goToMission();
            },
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
  }

  void _goToMission() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MissionApp(
          role: _missionToUse!.role,
          restoredMission: _missionToUse,
        ),
      ),
    );
  }

  void _goToRoleSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const RoleSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // écran neutre pendant la décision
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

