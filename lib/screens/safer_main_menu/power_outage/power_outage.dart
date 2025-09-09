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
    required IconData icon,
    Color? iconColor,
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: (iconColor ?? Theme.of(context).primaryColor)
                    .withOpacity(0.15),
                child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
              ),
              title: Text(
                heading,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Raleway',
                ),
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
                  style: const TextStyle(fontSize: 16, fontFamily: 'Raleway'),
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
    final beforeStormTips = [
      "Sign up for outage alerts & bookmark utility map",
      "Test generator (never indoors); keep fresh fuel, run 20+ ft from doors/windows",
      "Charge phones & backups",
      "Disengage garage door opener; know manual release",
      "Turn fridge/freezer to coldest setting",
      "Keep cash on hand (cards/ATMs may fail)",
      "Unplug non-essentials; add surge protection; leave 1 light on",
      "Prepare kit: flashlights, batteries, radio",
    ];

    final duringStormTips = [
      "Report outage once (utility app/site/phone)",
      "Stay away from downed or sparking lines → call 911",
      "Use flashlights/lanterns (no candles)",
      "Run generators outside only (20+ ft, exhaust away, transfer switch)",
      "Conserve phone battery (low-power, limit streaming, keep 1 device off)",
      "Keep fridge/freezer closed (fridge ~4 hrs, freezer ~48 hrs)",
    ];

    final afterStormTips = [
      "Assume all wires are live → report downed lines",
      "Check for electrical damage/smoke; call electrician if breakers trip",
      "Toss food above 40°F for 2+ hrs, or if smells/looks bad",
      "Reset outlets/clocks; power electronics back on carefully with surge protection",
      "Document damage (photos/video) before cleanup → insurance",
      "Restock supplies & fuel; review what worked for next time",
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: ListView(
        children: [
          buildInfoBlock(
            context,
            heading: "Before the Storm",
            tips: beforeStormTips,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/before-a-storm",
            ctaIcon: Icons.quiz_outlined,
            ctaTitle: 'Play: Preparedness Quiz',
            ctaSubtitle:
                'True/False about kits, charging devices, generators, and surge protection.',
            onPlay: () =>
                Navigator.pushNamed(context, Routes.beforeOutageQuiz),
          ),
          buildInfoBlock(
            context,
            heading: "During the Storm",
            tips: duringStormTips,
            icon: Icons.warning_amber,
            iconColor: Colors.orange,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/during-a-storm",
            ctaIcon: Icons.swap_horiz,
            ctaTitle: 'Play: Sort-It (During Outage)',
            ctaSubtitle:
                'Swipe items into HELPFUL vs NON-HELPFUL (flashlights, candles, generators, etc.).',
            onPlay: () =>
                Navigator.pushNamed(context, Routes.duringOutageSort),
          ),
          buildInfoBlock(
            context,
            heading: "After the Storm",
            tips: afterStormTips,
            icon: Icons.home,
            iconColor: Colors.blue,
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
