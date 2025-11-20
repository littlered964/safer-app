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
    _game = SaferAdventureGame(
      onExitToMenu: () {
        if (!mounted) return;
        Navigator.of(context).pop();
      },
    );
    _game.context = context;
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left reserved area with the room label (smaller + fixed width)
                  ValueListenableBuilder<String>(
                    valueListenable: _game.roomLabel,
                    builder: (context, text, _) {
                      const double sideReserve = 110; // was 140; smaller so D-pad gets more room
                      return SizedBox(
                        width: sideReserve,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                text, // room name
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.98),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              ValueListenableBuilder<String>(
                                valueListenable: _game.bumpLabel,
                                builder: (context, bump, _) => AnimatedOpacity(
                                  duration: const Duration(milliseconds: 120),
                                  opacity: bump.isEmpty ? 0.0 : 1.0,
                                  child: Text(
                                    bump,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontSize: 13,
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.95),
                                          fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Center: HARD guarantee a square for the D-pad so arrows fit
                  Expanded(
                    child: Center(
                      child: SizedBox.square(
                        dimension: 168, // same as container height so everything fits
                        child: _DPad(
                          onDir: (dx, dy) => _game.setMobileDir(dx, dy),
                          onStop: () => _game.setMobileDir(0, 0),
                        ),
                      ),
                    ),
                  ),

                  // Right-side: checklist toggle button (keeps total width symmetric with left)
                  SizedBox(
                    width: 110,
                    child: Center(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _game.checklistBadgeCount, // <-- from SaferAdventureGame
                        builder: (context, count, _) {
                          return Tooltip(
                            message: 'Open checklist',
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _game.toggleChecklist(); // game will clear the badge when opening
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(48, 48),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  child: const Text('☑', style: TextStyle(fontSize: 22)),
                                ),

                                // Notification bubble (top-right)
                                if (count > 0)
                                  const Positioned(
                                    right: -2,
                                    top: -2,
                                    child: _ChecklistBadge(),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistBadge extends StatelessWidget {
  const _ChecklistBadge();

  @override
  Widget build(BuildContext context) {
    // Optional: pull the current count if you want a number.
    // For a simple dot, ignore the count.
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
      ),
      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
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
        minimumSize: const WidgetStatePropertyAll(Size(70, 70)), // larger dead zone
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
