import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:safer/configs/routes.dart';

class PowerOutage extends StatelessWidget {
  final String title;
  const PowerOutage({super.key, required this.title});

  // ---- Generic info block with optional in-card CTA to play the relevant game
  Widget buildInfoBlock(
    BuildContext context, {
    required String heading,
    required List<String> tips,
    String? link,
    // CTA config (optional)
    IconData? ctaIcon,
    String? ctaTitle,
    String? ctaSubtitle,
    VoidCallback? onPlay,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 10),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("\u2022 ", style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (link != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(link)),
                child: Text(
                  'Learn more at Eversource',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
            if (onPlay != null && ctaTitle != null) ...[
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(ctaIcon ?? Icons.sports_esports_outlined),
                title: Text(
                  ctaTitle,
                  style: const TextStyle(fontFamily: 'Raleway'),
                ),
                subtitle: ctaSubtitle == null
                    ? null
                    : Text(
                        ctaSubtitle,
                        style: const TextStyle(fontFamily: 'Raleway'),
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: onPlay,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildRestorationBlock(BuildContext context) {
    const url =
        'https://www.eversource.com/content/residential/outages/restoration-process';
    const description =
        'Understand how Eversource restores power after major outages. This page outlines their step-by-step restoration process, prioritization of critical services, and estimated restoration timelines.';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Eversource Power Restoration",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(url)),
              child: Text(
                'Visit Restoration Process Page',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCtUtilitiesBlock(BuildContext context) {
    final links = <String, String>{
      'United Illuminating – Storm Checklist':
          'https://www.uinet.com/safety/stormsafety/stormchecklist',
      'United Illuminating – Outages': 'https://www.uinet.com/outages',
      'Groton Utilities – Outage Info':
          'https://grotonutilities.com/251/Outages#:~:text=There%20are%20currently%20no%20service%20outages.',
      'SNEW (South Norwalk) – Power Outage Tips':
          'https://www.snew.org/customer-care/power-outages/safety-tips-2/',
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'More from CT Utilities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Raleway',
              ),
            ),
            const SizedBox(height: 8),
            ...links.entries.map(
              (e) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  e.key,
                  style:
                      const TextStyle(fontSize: 16, fontFamily: 'Raleway'),
                ),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(Uri.parse(e.value)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ---- Tips content (unchanged)
    final beforeStormTips = [
      "Enroll in outage alerts and bookmark your utility’s outage map.",
      "Test your generator; NEVER run it indoors. Have fresh fuel and a safe outdoor spot (at least 20 ft from doors/windows).",
      "Charge mobile devices and backup batteries.",
      "Disengage electronic control for garage door; know how to manually open it.",
      "Set fridge/freezer to the coldest setting.",
      "Have cash on hand; card terminals and ATMs may be down.",
      "Add surge protection and unplug non-essential electronics; leave one light on so you know when power returns.",
      "Make an emergency kit with flashlights and radios."
    ];

    final duringStormTips = [
      "Report the outage once via your utility app/website or by phone. Don’t assume your neighbor reported it.",
      "Stay far away from downed or sparking lines; treat all as energized and call 9-1-1.",
      "Use flashlights or battery lanterns—avoid candles to reduce fire risk.",
      "Run generators OUTSIDE only, 20+ ft from openings, with exhaust pointed away. Use a transfer switch—never back-feed a home via an outlet.",
      "Conserve phone battery (low-power mode, limit streaming) and keep one device off for backup.",
      "Keep fridge/freezer closed: a fridge stays cold ~4 hours; a full freezer ~48 hours if unopened.",
    ];

    final afterStormTips = [
      "Assume lines are live and report downed wires. Keep kids and pets away.",
      "Check for electrical damage or the smell of smoke. If breakers trip repeatedly, call a licensed electrician.",
      "Toss perishable food that was above 40°F (4°C) for over 2 hours, or if it smells/looks off.",
      "Reset outlets and clocks; carefully power electronics back on with surge protection.",
      "Document any damage (photos/video) before cleanup for insurance claims.",
      "Replenish emergency supplies and fuel; review what worked and update your plan.",
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: ListView(
        children: [
          // BEFORE block + game CTA (Preparedness Quiz)
          buildInfoBlock(
            context,
            heading: "Before the Storm",
            tips: beforeStormTips,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/before-a-storm",
            ctaIcon: Icons.quiz_outlined,
            ctaTitle: 'Play: Preparedness Quiz',
            ctaSubtitle:
                'True/False about kits, charging devices, generators, and surge protection.',
            onPlay: () =>
                Navigator.pushNamed(context, Routes.beforeOutageQuiz),
          ),

          // DURING block + game CTA (Sorting / Safe vs Not Safe)
          buildInfoBlock(
            context,
            heading: "During the Storm",
            tips: duringStormTips,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/during-a-storm",
            ctaIcon: Icons.swap_horiz, // or Icons.swipe
            ctaTitle: 'Play: Sort-It (During Outage)',
            ctaSubtitle:
                'Swipe items into SAFE vs NOT SAFE (flashlights, candles, generators, etc.).',
            onPlay: () =>
                Navigator.pushNamed(context, Routes.duringOutageSort),
          ),

          // AFTER block + game CTA (Recovery Choices)
          buildInfoBlock(
            context,
            heading: "After the Storm",
            tips: afterStormTips,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/after-a-storm",
            ctaIcon: Icons.bolt_outlined,
            ctaTitle: 'Play: Recovery Choices',
            ctaSubtitle:
                'Make post-outage decisions (food safety, power-up sequence, generators).',
            onPlay: () =>
                Navigator.pushNamed(context, Routes.afterOutageChoices),
          ),

          buildRestorationBlock(context),
          buildCtUtilitiesBlock(context),
        ],
      ),
    );
  }
}
