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
  
  final List<Note> notes;

  NotesList({Key key, this.notes}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        return _buildRow(notes[i]);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget _buildRow(Note note) {
    return ListTile(
      title: Text(
        note.name,
        style: TextStyle(fontSize: 18.0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SaveNotePage()),
            ).then((a) => print('Atualizar view'));
        },
        tooltip: 'Show me the value!',
        child: Icon(Icons.text_fields),
      ),
    );
  }
}

class SaveNotePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: MyCustomForm(),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();
  String _value = ''; 

  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    onSaved: (value) => _value = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Nova nota';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          saveNote();
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Salvar'),
                    ),
                  ),
                ],
              ),
            )
          );
  }
  
  void saveNote() async {  
    var note = json.encode({'id': null, 'name': _value, 'status': false});
    await http.Client().post(
      'https://pacific-sea-93717.herokuapp.com/note', headers: {"Content-Type": "application/json"}, body: note);
  }
}
