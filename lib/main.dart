import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const FirstRoute(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<List<dynamic>> fetchUsers() async {
  final url = Uri.parse('https://cae821f268afdae372cb.free.beeceptor.com/api/users/');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    print('Resposta: ${response.body}');
    return jsonDecode(response.body);
  } else {
    print('Erro: ${response.statusCode}');
    {
      throw Exception('Failed to load data');
    }
  }
}

Future<void> createData(String nome, String sobrenome, String genero, int idade, String email) async {
  final response = await http.post(Uri.parse('https://cae821f268afdae372cb.free.beeceptor.com/api/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nome': nome,
        'sobrenome': sobrenome,
        'genero': genero,
        'idade': idade,
        'email': email
      }));
  if (response.statusCode != 200) {
    throw Exception('Failed to create data');
  }
}

Future<void> deleteData(String id) async {
  final response = await http.delete(Uri.parse('https://cae821f268afdae372cb.free.beeceptor.com/api/users/$id'));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete data');
  }
}

Future<void> updateData(int id) async {
  final response = await http.put(Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': 'Flutter HTTP CRUD',
        'body': 'This is an updated blog post about HTTP CRUD methods in Flutter',
        'userId': 1,
      }));

  if (response.statusCode != 200) {
    throw Exception('Failed to update data');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String nome="";
  String sobrenome="";
  String genero="";
  int idade=0;
  String email="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dados utilizando requisições HTTP'),
        ),
        body: Column(
          children: [
            Expanded(child: FutureBuilder<List<dynamic>>(
              future: fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else {
                  final data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      ElevatedButton(onPressed: () => null, child: Text("Deletar"));
                      sobrenome = data[index]['sobrenome'];
                      genero = data[index]['genero'];
                      idade = data[index]['idade'];
                      email = data[index]['email'];
                      return ListTile(
                        title: Text(data[index]['nome']),
                        subtitle: Text(
                            'Sobrenome: $sobrenome \nGênero: $genero\nIdade: $idade\nEmail: $email'),
                      );
                    },
                  );
                }
              },
            ),),
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SegundaJanela(title: 'Flutter Demo')),
              );
            }, child: const Text("Adicionar usuário")),
          ]
        ),
    );
  }
}

class SegundaJanela extends StatefulWidget {
  const SegundaJanela({super.key, required this.title});

  final String title;

  @override
  State<SegundaJanela> createState() => SecondRoute();
}

class SecondRoute extends State<SegundaJanela> {

  final _formKey = GlobalKey<FormState>();
  
  String nome="";
  String sobrenome="";
  String genero="";
  int idade=0;
  String email="";

  int groupRadio = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(10),
              child:
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um nome';
                  }
                  return null;
                },
                onChanged: (value) => nome=value,
                decoration: const InputDecoration(
                labelText: 'Digite seu nome')
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child:
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um sobrenome';
                  }
                  return null;
                },
                onChanged: (value) => sobrenome=value,
                decoration: const InputDecoration(
                labelText: 'Digite seu sobrenome')
              ),
            ),
            RadioListTile(title: const Text("Feminino"),value: 1,
              groupValue: groupRadio, onChanged: (int? value){setState((){
                genero = "Feminino";
                groupRadio = value!;
            });}),
            RadioListTile(title: const Text("Masculino"),value: 2,
              groupValue: groupRadio, onChanged: (int? value){setState((){
                genero = "Masculino";
                groupRadio = value!;
            });}),
            Container(
              margin: const EdgeInsets.all(10),
              child:
              TextFormField(
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite uma idade';
                  }
                  return null;
                },
                onChanged: (value) => idade = int.tryParse(value) ?? 0,
                decoration: const InputDecoration(
                labelText: 'Digite sua idade')
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child:
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um email';
                  }
                  return null;
                },
                onChanged: (value) => email=value,
                decoration: const InputDecoration(
                labelText: 'Digite seu email')
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: 
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    createData(nome, sobrenome, genero, idade, email);
                    setState(() {} );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ]
        ),
      )
    );
  }
}