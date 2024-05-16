import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=72939dfc";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double dolar;
  late double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.tryParse(text) ?? 0;
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.tryParse(text) ?? 0;
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.tryParse(text) ?? 0;
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 5,
        shadowColor: Colors.black,
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'Conversor',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );

            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao carregar dados',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar =
                    snapshot.data!['results']['currencies']['USD']['buy'] ?? 0;
                euro =
                    snapshot.data!['results']['currencies']['EUR']['buy'] ?? 0;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          'Reais', 'R\$ ', realController, _realChanged),
                      const Divider(
                        color: Colors.black,
                      ),
                      buildTextField(
                          'Dólares', 'US\$ ', dolarController, _dolarChanged),
                      const Divider(
                        color: Colors.black,
                      ),
                      buildTextField(
                          'Euro', 'E\$ ', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController control, Function funChange) {
  return TextField(
    controller: control,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: (text) {
      funChange(text);
    },
  );
}
