import 'package:flutter/material.dart';

class PowerOutage extends StatelessWidget {
  final String title;

  const PowerOutage({super.key, required this.title});

  Widget buildInfoBlock(String heading, List<String> tips) {
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
          buildInfoBlock("Before the Storm", beforeStormTips),
          buildInfoBlock("During the Storm", duringStormTips),
          buildInfoBlock("After the Storm", afterStormTips),
        ],
      ),
    );
  }
}
