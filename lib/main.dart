/*
 * Nombre: Melquisedec Mateo Neris
 * Matricula: 2022-0238
 */

import 'package:flutter/material.dart';
import 'menu.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const TabsControl(),
        debugShowCheckedModeBanner: false, // Esto sirve para esconder la etiqueta de modo de depuración.
        theme: ThemeData(
            primaryColor: Colors.blueAccent,
            appBarTheme: const AppBarTheme(color: Colors.blueAccent)
            )
    );
  }
}