import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aula6_exer6/geo.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  var textUmidade = 'Temperatura:';
  var textTemperatura = 'Umidade Relativa:';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.satellite_alt_rounded,
                    size: 30,
                  ),
                  Text(
                      style: TextStyle(
                        fontSize: 25,
                      ),
                      '  Sistema de Geolocalização'),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: latitudeController,
                decoration:
                    const InputDecoration(labelText: 'Digite a Latitude'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                  //Se colocar , ele pesquisa duas vezes.
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: longitudeController,
                decoration:
                    const InputDecoration(labelText: 'Digite a Longitude'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ' $textTemperatura',
              ),
              Text(
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  ' $textUmidade'),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: buscaGEO,
                child: const Text('Buscar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void buscaGEO() async {
    String latitude = latitudeController.text;
    String longitude = longitudeController.text;
    String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m&forecast_days=1';

    final resposta = await http.get(Uri.parse(url));
    if (resposta.body.length <= 21) {
      setState(() {
        latitudeController.clear();
        longitudeController.clear();
      });
    } else if (resposta.statusCode == 200) {
      // resposta 200 OK
      // o body contém JSON
      final jsonDecodificado = jsonDecode(resposta.body);
      final jsonTempoAtual = jsonDecodificado['current'];
      final valores = Geo.fromJson(jsonTempoAtual);
      setState(() {
        textTemperatura = 'Temperatura: ${valores.temperatura.toString()}' ;
        textUmidade = 'Umidade Relativa: ${valores.umidadeRelativa.toString()}';
      });
    } else {
      // diferente de 200
      setState(() {
      textTemperatura = 'Falha no carregamento dos dados.';
      textUmidade = '';
      });
    }
  }
}
