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
                channel = IOWebSocketChannel.connect('ws://$ipAddress:8887');
                // Enviar el mensaje al servidor
                String message = messageController.text;
                channel.sink.add(message);
              },
              child: Text('Connectar'),
            ),
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
}
