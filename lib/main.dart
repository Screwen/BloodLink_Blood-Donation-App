import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("fdfdfd"),
          backgroundColor: Colors.amber,
          centerTitle: true,
          leading: Icon(Icons.home),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.back_hand_sharp),
            ),
          ],
        ),
        body: ListView(children: [Text("Hello"), Text("fdgfdgfdgf")]),
      ),
    );
  }
}
