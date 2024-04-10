// ignore_for_file: prefer_const_constructors

/*
 * Nombre: Melquisedec Mateo Neris
 * Matricula: 2022-0238
 */

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class EventList extends StatefulWidget {
  const EventList({Key? key}) : super(key: key);

  @override
  EventListState createState() => EventListState();
}

class EventListState extends State<EventList> {
  late Database db;
  List<Map<String, dynamic>> _events = [];
  late FlutterSoundPlayer soundPlayer = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    _openDatabase();
    _initPlayer();
  }

  Future<void> _openDatabase() async {
    final dbpath = await getDatabasesPath();
    final rpath = p.join(dbpath, 'events.db');

    db = await openDatabase(rpath);
    _loadEvent();
  }

  Future<void> _initPlayer() async {
    await soundPlayer.openPlayer();
  }

  Future<void> _loadEvent() async {
    final List<Map<String, dynamic>> events = await db.query('event');

    setState(() {
      _events = events;
    });
  }

  Future<void> _playAudio(String path) async {
    await soundPlayer.startPlayer(
      fromURI: path,
      codec: Codec.aacADTS,
    );
  }

  Future<void> _deleteAllEvents() async {
    if (!db.isOpen) {
      await _openDatabase();
    }

    await db.delete("event");
    setState(() {
      _events = [];
    });
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirma eliminar'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('¿Estás seguro de que quieres eliminar todos los eventos?'),
                Text('Esta acción no se puede recuperar.'),
              ],
            ),
          ),
          actions: <Widget>[
                        TextButton(
              child: const Text('Refresh'),
              onPressed: () {
                Navigator.of(context).pop();
                _loadEvent();
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                _deleteAllEvents();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    db.close();
    soundPlayer.closePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de todos los eventos')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondos.png'), 
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.2),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _events.map((event) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextButton(
                      onPressed: () {
                        _showEventDetails(event);
                      },
                      child: Text(event['event_title']),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _showDeleteConfirmationDialog,
        tooltip: 'Refresh o Eliminar todos los eventos',
        child: const Icon(Icons.delete_forever),
      ),
    );
  }

  Future<void> _showEventDetails(Map<String, dynamic> event) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event['event_title']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (event['event_photo_path'] != null)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: FileImage(File(event['event_photo_path'])),
                  ),
                const SizedBox(height: 10),
                Text('Fecha: ${event['event_date']}'),
                const SizedBox(height: 10),
                Text('Descripción: ${event['event_description']}'),
                if (event['event_audio_path'] != null)
                  ElevatedButton(
                    onPressed: () => _playAudio(event['event_audio_path']),
                    child: const Text('Escuchar Nota de Voz'),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
