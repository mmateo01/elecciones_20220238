// ignore_for_file: prefer_const_constructors, use_super_parameters

/*
 * Nombre: Melquisedec Mateo Neris
 * Matricula: 2022-0238
 */
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  AddEventState createState() => AddEventState();
}

class AddEventState extends State<AddEvent> {
  DateTime? _selectedDate;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _photoPath;
  String? _audioPath;
  FlutterSoundRecorder? _audioRecorder = FlutterSoundRecorder();

  late Database db;

  @override
  void initState() {
    super.initState();
    _openDatabase();
    _initRecorder();
  }

  Future<void> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'events.db');

    db = await openDatabase(path, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS event (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_date TEXT,
        event_title TEXT,
        event_description TEXT,
        event_photo_path TEXT,
        event_audio_path TEXT
      )
    ''');
    }, version: 1);
  }

  void _closeDatabase() async {
    await db.close();
  }

  @override
  void dispose() {
    _closeDatabase();
    _closeRecorder();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

   Future<void> _insertEvent() async {

    final formattedDate = _selectedDate?.toIso8601String();

    await db.transaction((txn) async {
      await txn.insert(
          'event',
          {
            'event_date': formattedDate,
            'event_title': "Evento ${_titleController.text}",
            'event_description': _descriptionController.text,
            'event_photo_path': _photoPath,
            'event_audio_path': _audioPath
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    _titleController.text = '';
    _descriptionController.text = '';
    _photoPath = '';
    _audioPath = '';
    _selectedDate = null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await _audioRecorder?.openRecorder();
  }

  Future<void> _closeRecorder() async {
    if (_audioRecorder != null) {
      await _audioRecorder?.closeRecorder();
      _audioRecorder = null;
    }
  }

  Future<void> _startStopRecording() async {
    if (_audioRecorder?.isRecording ?? false) {
      final path = await _audioRecorder?.stopRecorder();
      setState(() {
        _audioPath = path;
      });
    } else {
      await _audioRecorder?.startRecorder(
          toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}');
      setState(() {});
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de eventos')),
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Evento'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Detalles de Evento'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(_selectedDate != null ? 'Fecha: ${_selectedDate!.toString().split(' ')[0]}' : 'Seleccionar Fecha'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Elija o Tome Foto'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startStopRecording,
                    child: _audioRecorder?.isRecording ?? false
                        ? const Text('Detiene Grabación')
                        : const Text('Inicia Grabación'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _insertEvent(),
                    child: const Text('Agrega evento'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
