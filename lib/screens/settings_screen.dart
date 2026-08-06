import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boul_o_metre/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _horizontalThreshold = 0.2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _horizontalThreshold = prefs.getDouble('horizontalThreshold') ?? 0.2;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('horizontalThreshold', _horizontalThreshold);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réglages sauvegardés')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sensibilité de l\'horizontalité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  const Text(
                    'Ajustez la sensibilité requise pour que le bouton de capture soit activé. ',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Row(
                    children: [
                      const Text('Moins sensible'),
                      Expanded(
                        child: Slider(
                          value: _horizontalThreshold,
                          min: 0.05,
                          max: 0.3,
                          divisions: 25,
                          label: _horizontalThreshold.toStringAsFixed(2),
                          onChanged: (value) {
                            setState(() {
                              _horizontalThreshold = value;
                            });
                          },
                        ),
                      ),
                      const Text('Plus sensible'),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Valeur actuelle: ${_horizontalThreshold.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  const Text(
                    'Conseils:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  const Text(
                    '- Une valeur basse (0.05-0.1) nécessite un téléphone très horizontal',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  const Text(
                    '- Une valeur haute (0.2-0.3) est plus tolérante',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.defaultPadding,
                        ),
                      ),
                      child: const Text('Sauvegarder'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
