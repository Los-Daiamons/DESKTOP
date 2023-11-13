import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyForm(),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  late WebSocketChannel channel;
  late String connectionName = '';
  int mobileConnections = 0;
  int desktopConnections = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desktop App para controlar el panel LED'),
      ),
      body: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Mensaje'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'Dirección IP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Establecer la conexión WebSocket al presionar el botón "Connectar"

                String ipAddress = ipController.text;
                connectionName = "desktop";

                channel = IOWebSocketChannel.connect(
                    'ws://$ipAddress:8887?name=$connectionName');
                // Enviar el mensaje al servidor
                connectToWebSocket();
                channel.sink.add("desktop");
              },
              child: Text('Connectar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Enviar el mensaje al servidor
                String message = messageController.text;
                channel.sink.add(message);
              },
              child: Text('Enviar'),
            ),
            SizedBox(height: 20),
            Text('Conexión: $connectionName'),
            SizedBox(height: 20),
            Text('Conexiones móviles: $mobileConnections'),
            Text('Conexiones de escritorio: $desktopConnections'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cerrar la conexión WebSocket al salir de la página
    channel.sink.close();
    super.dispose();
  }

  void connectToWebSocket() {
    // Manejar la conexión al WebSocket aquí
    //channel.sink.add("desktop");

    // Escuchar mensajes del servidor
    channel.stream.listen((message) {
      Map<String, dynamic> data = json.decode(message);

      // Manejar el mensaje del servidor según la estructura de tus datos
      if (data["type"] == "connection_count") {
        setState(() {
          mobileConnections = data["mobile_connections"];
          desktopConnections = data["desktop_connections"];
        });
      }
    });
  }
}
