import 'package:flutter/material.dart';
import 'view/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMart',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ProductListView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
