// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables

/*
 * Nombre: Melquisedec Mateo Neris
 * Matricula: 2022-0238
 */

import 'package:flutter/material.dart';
import 'package:eleccionesapp/newevent.dart';
import 'package:eleccionesapp/events.dart';
import 'package:eleccionesapp/about.dart';

class TabsControl extends StatefulWidget {
  const TabsControl({key}) : super(key: key);

  @override
  _TabsControlState createState() => _TabsControlState();
}

class _TabsControlState extends State<TabsControl> {
  int _currentIndex = 0;
  

  final List<Widget> _children = [
    AddEvent(),
    EventList(),
    AboutMe(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Elecciones Events 2024'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Agregar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Acerca de',
          ),
        ],
      ),
    );
  }
}
