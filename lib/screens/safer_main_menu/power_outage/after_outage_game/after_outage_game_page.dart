import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'after_outage_adventure.dart';

class AfterOutageGamePage extends StatefulWidget {
  const AfterOutageGamePage({super.key});

  @override
  State<AfterOutageGamePage> createState() => _AfterOutageGamePageState();
}

class _AfterOutageGamePageState extends State<AfterOutageGamePage> {
  late final SaferAdventureGame _game;

  @override
  void initState() {
    super.initState();
    _game = SaferAdventureGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('After the Storm — Adventure')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: GameWidget<SaferAdventureGame>(game: _game),
            ),
          ),
          // D-Pad: taller + semi-transparent + bigger center dead-zone
          Container(
            height: 168,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.86),
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: _DPad(
              onDir: (dx, dy) => _game.setMobileDir(dx, dy),
              onStop: () => _game.setMobileDir(0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _DPad extends StatelessWidget {
  final void Function(double dx, double dy) onDir;
  final VoidCallback onStop;

  const _DPad({required this.onDir, required this.onStop});

  @override
  Widget build(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(
      shape: const CircleBorder(),
      minimumSize: const Size(76, 76), // bigger buttons
      padding: EdgeInsets.zero,
      elevation: 2,
    );

    Widget holdButton(IconData icon, double dx, double dy) {
      return Listener(
        onPointerDown: (_) => onDir(dx, dy),
        onPointerUp: (_) => onStop(),
        onPointerCancel: (_) => onStop(),
        child: ElevatedButton(
          style: btnStyle,
          onPressed: () {},
          child: Icon(icon, size: 28),
        ),
      );
    }

    // Large center stop button acts as a "dead zone"
    final stopButton = ElevatedButton(
      style: btnStyle.copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(92, 92)), // larger dead zone
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      onPressed: onStop,
      child: const Icon(Icons.circle, size: 18),
    );

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top: 4, child: holdButton(Icons.keyboard_arrow_up, 0, -1)),
            Positioned(bottom: 4, child: holdButton(Icons.keyboard_arrow_down, 0, 1)),
            Positioned(left: 4, child: holdButton(Icons.keyboard_arrow_left, -1, 0)),
            Positioned(right: 4, child: holdButton(Icons.keyboard_arrow_right, 1, 0)),
            stopButton,
          ],
        ),
      ),
    );
  }
}
