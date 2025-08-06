import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PowerOutage extends StatelessWidget {
  final String title;

  const PowerOutage({super.key, required this.title});

  Widget buildInfoBlock(
    BuildContext context,
    String heading,
    List<String> tips, {
    String? link,
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
            ...tips.map((tip) => Padding(
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
                )),
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
          ],
        ),
      ),
    );
  }

  Widget buildRestorationBlock(BuildContext context) {
    const url = 'https://www.eversource.com/content/residential/outages/restoration-process';
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

  @override
  Widget build(BuildContext context) {
    final beforeStormTips = [
      "Charge mobile devices and backup batteries.",
      "Stock up on food, water, and medications.",
      "Secure outdoor furniture and trim tree branches.",
      "Know how to manually open your garage door.",
      "Make an emergency kit with flashlights and radios."
    ];

    final duringStormTips = [
      "Stay indoors and away from windows.",
      "Avoid using candles due to fire risk.",
      "Report outages to Eversource using the app or website.",
      "Limit opening refrigerator and freezer doors.",
      "Unplug sensitive electronics to prevent surges."
    ];

    final afterStormTips = [
      "Check on neighbors, especially elderly or vulnerable.",
      "Stay away from downed power lines.",
      "Restock emergency supplies.",
      "Safely discard perishable food that may have spoiled.",
      "Review and improve your outage preparedness plan."
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
            "Before the Storm",
            beforeStormTips,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/before-a-storm",
          ),
          buildInfoBlock(
            context,
            "During the Storm",
            duringStormTips,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/during-a-storm",
          ),
          buildInfoBlock(
            context,
            "After the Storm",
            afterStormTips,
            link:
                "https://www.eversource.com/content/residential/outages/storm-preparedness/after-a-storm",
          ),
          buildRestorationBlock(context),
        ],
      ),
    );
  }
}
