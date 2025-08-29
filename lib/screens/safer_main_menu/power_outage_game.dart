import 'dart:math';
import 'package:flutter/material.dart';

class PowerOutageGame extends StatefulWidget {
  final String title;

  /// Title is optional so you don't have to pass it in routes.dart
  const PowerOutageGame({super.key, this.title = 'Power Outage Game'});

  @override
  State<PowerOutageGame> createState() => _PowerOutageGameState();
}

class _PowerOutageGameState extends State<PowerOutageGame> {
  final _rng = Random();

  /// One round = classify one item. Wrong answer ends the run.
  /// You can expand this later into lives/timers/falling animations.
  int _score = 0;
  _Item? _current;

  /// Pool of items to classify.
  /// `helpful == true` means it belongs in the Helpful bin.
  final List<_Item> _pool = [
    // Helpful items
    _Item('Flashlight', Icons.flashlight_on_outlined, true,
        tip: 'Use flashlights or battery lanterns—avoid candles.'),
    _Item('Batteries', Icons.battery_full, true,
        tip: 'Spare batteries keep lights and radios running.'),
    _Item('Portable Radio', Icons.radio, true,
        tip: 'Battery radios provide updates if internet is down.'),
    _Item('Surge Protector', Icons.power_rounded, true,
        tip: 'Protect sensitive electronics from surges.'),
    _Item('Cooler with Ice', Icons.icecream, true,
        tip: 'Helps keep perishables cold during outages.'),
    _Item('First Aid Kit', Icons.medical_services_outlined, true,
        tip: 'For minor injuries when services are delayed.'),

    // Not helpful / risky items
    _Item('Candle', Icons.candlestick_chart, false,
        tip: 'Fire risk during storms—prefer flashlights.'),
    _Item('Gas Stove for Heating', Icons.local_fire_department, false,
        tip: 'CO risk—never use for heating.'),
    _Item('Backfeeding with Cord', Icons.electrical_services_outlined, false,
        tip: 'Extremely dangerous—use a transfer switch.'),
    _Item('Wet Extension Cord', Icons.power_off, false,
        tip: 'Shock hazard—keep cords dry and intact.'),
  ];

  @override
  void initState() {
    super.initState();
    _nextItem();
  }

  void _nextItem() {
    setState(() {
      _current = _pool[_rng.nextInt(_pool.length)];
    });
  }

  void _choose(bool userThinksHelpful) {
    if (_current == null) return;
    final correct = _current!.helpful == userThinksHelpful;

    if (correct) {
      setState(() => _score++);
      _nextItem();
    } else {
      _gameOver();
    }
  }

  Future<void> _gameOver() async {
    final item = _current;
    final finalScore = _score;
    // Reset state for next round
    setState(() {
      _score = 0;
      _current = null;
    });

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Final score: $finalScore'),
            const SizedBox(height: 8),
            if (item != null) ...[
              Text(
                'Item: ${item.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(item.helpful ? 'Correct bin: Helpful' : 'Correct bin: Not Helpful'),
              if (item.tip != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.tip!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ]
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextItem();
            },
            child: const Text('Play Again'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _current == null
          ? Center(
              child: ElevatedButton(
                onPressed: _nextItem,
                child: const Text('Start'),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Score: $_score',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card with the current item
                  Expanded(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _current!.icon,
                              size: 96,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _current!.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_current!.tip != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  _current!.tip!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Two big buttons: Helpful vs Not Helpful
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _choose(true),
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text('Helpful'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _choose(false),
                          icon: const Icon(Icons.thumb_down_alt_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Text('Not Helpful'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Sort the item into the correct bin.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }
}

class _Item {
  final String name;
  final IconData icon;
  final bool helpful;
  final String? tip;

  const _Item(this.name, this.icon, this.helpful, {this.tip});
}
