import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/theme_config.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_bottom_nav.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _countControllers = {};
  late List<String> _activePrizeLevels;
  late final TextEditingController _ticketPriceController;
  late String _selectedThemeName;

  @override
  void initState() {
    super.initState();
    final ticketProvider = context.read<TicketProvider>();
    _activePrizeLevels = List.from(ticketProvider.prizeLevels);

    for (final level in TicketProvider.allPrizeLevels) {
      _countControllers[level] = TextEditingController(
        text: (ticketProvider.prizeCounts[level] ?? 0).toString(),
      );
    }
    _ticketPriceController = TextEditingController(
      text: ticketProvider.ticketPrice.toString(),
    );
    _selectedThemeName = ticketProvider.themeName;
  }

  @override
  void dispose() {
    for (final controller in _countControllers.values) {
      controller.dispose();
    }
    _ticketPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final prizeCounts = {
      for (final level in _activePrizeLevels)
        level: int.parse(_countControllers[level]!.text),
    };
    final ticketPrice = int.parse(_ticketPriceController.text);

    await context.read<TicketProvider>().updateSettings(
          prizeLevels: _activePrizeLevels,
          prizeCounts: prizeCounts,
          ticketPrice: ticketPrice,
          themeName: _selectedThemeName,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved and tickets reset.'),
      ),
    );
  }

  String? _validateNumber(String? value) {
    final number = int.tryParse(value ?? '');
    if (number == null) {
      return 'Enter a number';
    }
    if (number < 0) {
      return 'Use 0 or more';
    }
    return null;
  }

  void _addPrizeLevel() {
    if (_activePrizeLevels.length >= TicketProvider.maxPrizeLevelCount) return;

    setState(() {
      final nextLevel =
          TicketProvider.allPrizeLevels[_activePrizeLevels.length];
      _activePrizeLevels.add(nextLevel);
      if (_countControllers[nextLevel]!.text.isEmpty) {
        _countControllers[nextLevel]!.text = '0';
      }
    });
  }

  void _removePrizeLevel() {
    if (_activePrizeLevels.length <= TicketProvider.minPrizeLevelCount) return;

    setState(() {
      _activePrizeLevels.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Total tickets: ${ticketProvider.totalTicketCount}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ticketPriceController,
                  decoration: const InputDecoration(
                    labelText: '티켓 가격',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateNumber,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedThemeName,
                  decoration: const InputDecoration(
                    labelText: '테마',
                    border: OutlineInputBorder(),
                  ),
                  items: availableThemes
                      .map(
                        (themeName) => DropdownMenuItem(
                          value: themeName,
                          child: Text(themeName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedThemeName = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '상품 개수 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _activePrizeLevels.length >
                              TicketProvider.minPrizeLevelCount
                          ? _removePrizeLevel
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      tooltip: '상품 등급 제거',
                    ),
                    IconButton(
                      onPressed: _activePrizeLevels.length <
                              TicketProvider.maxPrizeLevelCount
                          ? _addPrizeLevel
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: '상품 등급 추가',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._activePrizeLevels.map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _countControllers[level],
                      decoration: InputDecoration(
                        labelText: '$level 상 개수',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateNumber,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saveSettings,
                  child: const Text('설정 저장 및 티켓 초기화'),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
