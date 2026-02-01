import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // pour textinputformater
import 'package:latlong2/latlong.dart';
import '../model/geo_utils.dart';

class MGRSInput extends StatelessWidget {
  final String initialGzd;
  final String initialSquare;

  // callback exécutée dans _PcTirInputScreenState
  final ValueChanged<LatLng> onPositionValidated;

  const MGRSInput({
    super.key,
    required this.initialGzd,
    required this.initialSquare,
    required this.onPositionValidated,
  });

  @override
  Widget build(BuildContext context) {

    return MgrsInputForm(
        initialGzd: initialGzd,
        initialSquare: initialSquare,
        onValidatedMGRSString: (mgrsString) {
          debugPrint('📥 MGRS reçue dans MGRSInput : $mgrsString');

          // Conversion inverse MGRS -> LatLng
          final latLng = Mgrs_100mToLatLng(mgrsString);
          debugPrint('🎯 Position saisie $latLng');

          // Appel à la callback pour retourner la position
          // à _PcTirInputScreenState
          onPositionValidated(latLng);
        }
    );
  }
}

/// *************************
///  APPELLEE PAR MGRSInput *
///  Proposition de la zone et du carré par défaut
///  zones de saisie de l'earthing/northing sur 3 chiffres (100m)
/// ***********************
class MgrsInputForm extends StatefulWidget {
  final String initialGzd;
  final String initialSquare;

  // callback renvoyée à MGRSInput quand la MGRS est validée
  final ValueChanged<String> onValidatedMGRSString;

  const MgrsInputForm( {
    super.key,
    required this.initialGzd,
    required this.initialSquare,
    required this.onValidatedMGRSString,
  });

  @override
  State<MgrsInputForm> createState() => _MgrsInputFormState();

} //_MgrsInputForm

class _MgrsInputFormState extends State<MgrsInputForm> {
  late final TextEditingController _gzdCtrl;
  late final TextEditingController _squareCtrl;
  final _eastingCtrl  = TextEditingController();
  final _northingCtrl = TextEditingController();

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _gzdCtrl    = TextEditingController(text: widget.initialGzd);
    _squareCtrl = TextEditingController(text: widget.initialSquare);

    _gzdCtrl.addListener(_onFieldChanged);
    _squareCtrl.addListener(_onFieldChanged);
    _eastingCtrl.addListener(_onFieldChanged);
    _northingCtrl.addListener(_onFieldChanged);
  }

  @override
  void didUpdateWidget(covariant MgrsInputForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialGzd != widget.initialGzd &&
        _gzdCtrl.text.isEmpty) {
      _gzdCtrl.text = widget.initialGzd;
    }

    if (oldWidget.initialSquare != widget.initialSquare &&
        _squareCtrl.text.isEmpty) {
      _squareCtrl.text = widget.initialSquare;
    }
  }

  // retour de la ValueChanged
  void _onFieldChanged() {
    final isNowValid = _isFormValid();
    if (isNowValid && !_isValid) {
      final mgrs =
          '${_gzdCtrl.text} ${_squareCtrl.text} '
          '${_eastingCtrl.text} ${_northingCtrl.text}';

      debugPrint('✅ MGRS complète → émission automatique');

      widget.onValidatedMGRSString(mgrs);
    }

    setState(() {
      _isValid = isNowValid;
    });
  }

  // reconstruit la MGRS saisie si valide
  // (testée par _isFormValid) et retourne la ValueChanged
  void _validate() {
    final mgrs =
        '${_gzdCtrl.text} ${_squareCtrl.text} '
        '${_eastingCtrl.text} ${_northingCtrl.text}';
    debugPrint('✅ Validation MGRS déclenchée $mgrs');
    widget.onValidatedMGRSString(mgrs);
  }

  // teste si la forme générale de la MGRS est correcte
  // a minima le nombre de caractères de chaque élement
  // @todo amélioration de la vérification !
  bool _isFormValid() {
    return _gzdCtrl.text.length == 3 &&
        _squareCtrl.text.length == 2 &&
        _eastingCtrl.text.length == 3 &&
        _northingCtrl.text.length == 3;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 8),

        Row(
          children: [
            // GZD
            Expanded(
              flex: 2,
              child: TextField(
                controller: _gzdCtrl,
                maxLength: 3,
                decoration: const InputDecoration(
                  labelText: 'Zone',
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  UpperCaseTextFormatter(), // ✅ clé
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Square
            Expanded(
              flex: 2,
              child: TextField(
                controller: _squareCtrl,
                maxLength: 2,
                decoration: const InputDecoration(
                  labelText: 'Carré',
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // saisie du easting
            Expanded(
              flex: 2,
              child: TextField(
                controller: _eastingCtrl,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'E',

                  hint: RichText(
                    text: TextSpan(
                    children: [
                      TextSpan(
                        text: '000',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextSpan(
                        text: '00',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Northing
            Expanded(
              flex: 2,
              child: TextField(
                controller: _northingCtrl,
                keyboardType: TextInputType.number,
                maxLength: 3,

                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'N',
                  hint: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '000',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        TextSpan(
                          text: '00',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}// _MgrsInputFormState

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}