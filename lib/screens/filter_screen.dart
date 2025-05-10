import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String selectedType = "All";
  String selectedGender = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Filter")),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedType,
            items: ["All", "Cats", "Dogs"].map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },
          ),
          DropdownButton<String>(
            value: selectedGender,
            items: ["All", "Male", "Female"].map((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Implement filtering logic
            },
            child: Text("Filter"),
          ),
        ],
      ),
    );
  }
}