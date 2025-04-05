import 'package:flutter/material.dart';
import 'available_vehicles_screen.dart';

class WhereToScreen extends StatefulWidget {
  @override
  _WhereToScreenState createState() => _WhereToScreenState();
}

class _WhereToScreenState extends State<WhereToScreen> {
  final Map<String, List<String>> categorizedDestinations = {
    "Main Roads": ["Thika Road", "Jogoo Road", "Mombasa Road", "Ngong Road"],
    "Estates": ["Donholm", "Buruburu", "Kasarani", "Lang'ata", "South B", "South C", "Umoja"],
    "Towns/Outskirts": ["Ruiru", "Kikuyu", "Kitengela", "Ngong", "Athi River", "Limuru", "Thika"]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Where to?", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: categorizedDestinations.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Text(
                  entry.key,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              Column(
                children: entry.value.map((destination) {
                  return ListTile(
                    title: Text(destination, style: TextStyle(fontSize: 16)),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvailableVehiclesScreen(destination: destination),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
