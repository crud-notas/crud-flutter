import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Note>> fetchNotes(http.Client client) async {  
  final response = await client.get('https://pacific-sea-93717.herokuapp.com/note');
  final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
  return parsed.map<Note>((json) => Note.fromJson(json)).toList();
}

class Note {
  final int id;
  final String name;
  final bool status;

  Note({this.id, this.name, this.status});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      name: json['name'],
      status: json['status'],
    );
  }
}

class NotesList extends StatelessWidget {
  
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final List<Note> notes;

  NotesList({Key key, this.notes}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        // if (i.isOdd) return Divider(); 
        return _buildRow(notes[i]);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget _buildRow(Note note) {
    return ListTile(
      title: Text(
        note.name,
        style: _biggerFont,
      ),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'crudESIG';

    return MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Note>>(
        future: fetchNotes(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? NotesList(notes: snapshot.data)
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}