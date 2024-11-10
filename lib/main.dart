import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

const String link =
    "https://ca8852438d6058dcff62.free.beeceptor.com/api/users/";

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
  State<MyHomePage> createState() => JanelaPrincipal();
}

Future<List<dynamic>> fetchUsers() async {
  final url = Uri.parse(link);
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Text('Resposta: ${response.body}');
    return jsonDecode(response.body);
  } else {
    Text('Erro: ${response.statusCode}');
    {
      throw Exception('Failed to load data');
    }
  }
}

Future<dynamic> usuario(String id) async {
  final url = Uri.parse('$link$id');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    Text('Resposta: ${response.body}');
    return jsonDecode(response.body);
  } else {
    Text('Erro: ${response.statusCode}');
    {
      throw Exception('Failed to load data');
    }
  }
}

Future<void> createData(String nome, String sobrenome, String genero, int idade,
    String email) async {
  final response = await http.post(Uri.parse(link),
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
  final response = await http.delete(Uri.parse('$link$id'));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete data');
  }
}

Future<void> updateData(String id, String nome, String sobrenome, String genero,
    int idade, String email) async {
  final response = await http.put(Uri.parse('$link$id'),
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
    throw Exception('Failed to update data');
  }
}

class JanelaPrincipal extends State<MyHomePage> {
  String nome = "";
  String sobrenome = "";
  String genero = "";
  int idade = 0;
  String email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados utilizando requisições HTTP'),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        Expanded(
            child: FutureBuilder<List<dynamic>>(
                future: fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else {
                    final data = snapshot.data!;
                    if (data.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            child: const Text("Nenhum cadastro encontrado"),
                          )
                        ],
                      );
                    } else {
                      return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            sobrenome = data[index]['sobrenome'];
                            genero = data[index]['genero'];
                            idade = data[index]['idade'];
                            email = data[index]['email'];
                            String id = data[index]['id'];
                            return ListTile(
                              trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 6),
                                        height: 25,
                                        child: ElevatedButton(
                                            onPressed: () => {
                                                  setState(() {
                                                    deleteData(id);
                                                  })
                                                },
                                            child: const Text("Apagar"))),
                                    SizedBox(
                                        height: 25,
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              final resultado =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        JanelaEditar(
                                                            idPessoa: id)),
                                              );
                                              if (resultado == 'atualizar') {
                                                setState(() {});
                                              }
                                            },
                                            child: const Text("Editar"))),
                                  ]),
                              contentPadding: const EdgeInsets.all(8),
                              minTileHeight: 100,
                              title: Text(data[index]['nome']),
                              subtitle: Text(
                                  'Sobrenome: $sobrenome \nGênero: $genero\nIdade: $idade\nEmail: $email'),
                            );
                          });
                    }
                  }
                })),
        ElevatedButton(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const SegundaJanela(title: 'Flutter Demo')),
              );
              if (resultado == 'atualizar') {
                setState(() {});
              }
            },
            child: const Text("Adicionar usuário")),
      ]),
    );
  }
}

class SegundaJanela extends StatefulWidget {
  const SegundaJanela({super.key, required this.title});

  final String title;

  @override
  State<SegundaJanela> createState() => JanelaDois();
}

class JanelaDois extends State<SegundaJanela> {
  final _formKey = GlobalKey<FormState>();

  String nome = "";
  String sobrenome = "";
  String genero = "";
  int idade = 0;
  String email = "";

  int groupRadio = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Criação de novo usuário'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite um nome';
                        }
                        return null;
                      },
                      onChanged: (value) => nome = value,
                      decoration:
                          const InputDecoration(labelText: 'Digite seu nome')),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite um sobrenome';
                        }
                        return null;
                      },
                      onChanged: (value) => sobrenome = value,
                      decoration: const InputDecoration(
                          labelText: 'Digite seu sobrenome')),
                ),
                RadioListTile(
                    title: const Text("Feminino"),
                    value: 1,
                    groupValue: groupRadio,
                    onChanged: (int? value) {
                      setState(() {
                        genero = "Feminino";
                        groupRadio = value!;
                      });
                    }),
                RadioListTile(
                    title: const Text("Masculino"),
                    value: 2,
                    groupValue: groupRadio,
                    onChanged: (int? value) {
                      setState(() {
                        genero = "Masculino";
                        groupRadio = value!;
                      });
                    }),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite uma idade';
                        }
                        return null;
                      },
                      onChanged: (value) => idade = int.tryParse(value) ?? 0,
                      decoration:
                          const InputDecoration(labelText: 'Digite sua idade')),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite um email';
                        }
                        return null;
                      },
                      onChanged: (value) => email = value,
                      decoration:
                          const InputDecoration(labelText: 'Digite seu email')),
                ),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createData(nome, sobrenome, genero, idade, email);
                        Navigator.pop(context, 'atualizar');
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ]),
        ));
  }
}

class JanelaEditar extends StatefulWidget {
  const JanelaEditar({super.key, required this.idPessoa});

  final String idPessoa;

  @override
  State<JanelaEditar> createState() => JanelaEdicao();
}

class JanelaEdicao extends State<JanelaEditar> {
  final _formKey = GlobalKey<FormState>();

  String nome = "";
  String sobrenome = "";
  String genero = "";
  int idade = 0;
  String email = "";

  int inicio = 1;

  int groupRadio = 0;

  @override
  void initState() {
    super.initState();
    conexao = usuario(widget.idPessoa);
  }

  late Future<dynamic> conexao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edição de Usuário'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: conexao,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      } else {
                        final data = snapshot.data!;
                        nome = data['nome'];
                        sobrenome = data['sobrenome'];
                        idade = data['idade'];
                        email = data['email'];
                        if (inicio == 1) {
                          genero = data['genero'];
                          inicio++;
                        }
                        if (genero == "Feminino") {
                          groupRadio = 1;
                        } else {
                          groupRadio = 2;
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextFormField(
                                  initialValue: data['nome'],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite um nome';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => nome = value,
                                  decoration: const InputDecoration(
                                      labelText: 'Digite seu nome')),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextFormField(
                                  initialValue: data['sobrenome'],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite um sobrenome';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => sobrenome = value,
                                  decoration: const InputDecoration(
                                      labelText: 'Digite seu sobrenome')),
                            ),
                            RadioListTile(
                                title: const Text("Feminino"),
                                value: 1,
                                groupValue: groupRadio,
                                onChanged: (int? value) {
                                  setState(() {
                                    genero = "Feminino";
                                    groupRadio = 1;
                                  });
                                }),
                            RadioListTile(
                                title: const Text("Masculino"),
                                value: 2,
                                groupValue: groupRadio,
                                onChanged: (int? value) {
                                  setState(() {
                                    genero = "Masculino";
                                    groupRadio = 2;
                                  });
                                }),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextFormField(
                                  initialValue: data['idade'].toString(),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite uma idade';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) =>
                                      idade = int.tryParse(value) ?? 0,
                                  decoration: const InputDecoration(
                                      labelText: 'Digite sua idade')),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              child: TextFormField(
                                  initialValue: data['email'],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, digite um email';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => email = value,
                                  decoration: const InputDecoration(
                                      labelText: 'Digite seu email')),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    updateData(widget.idPessoa, nome, sobrenome,
                                        genero, idade, email);
                                    Navigator.pop(context, 'atualizar');
                                  }
                                },
                                child: const Text('Atualizar'),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ]),
        ));
  }
}
