import 'dart:convert';
import 'dart:io';

import 'package:desktop/messageListScreen.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class Message {
  final String text;
  final DateTime timestamp;

  Message({required this.text, required this.timestamp});
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyForm(),
    );
  }
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  late WebSocketChannel channel = IOWebSocketChannel.connect('');
  late String connectionName = '';
  int mobileConnections = 0;
  int desktopConnections = 0;
  List<Message> messages = [];
  String estado = 'Desconectado';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Mensaje'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(labelText: 'Dirección IP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Establecer la conexión WebSocket al presionar el botón "Connectar"

                String ipAddress = ipController.text;
                connectionName = "desktop";

                channel = IOWebSocketChannel.connect(
                    'ws://$ipAddress:8887?name=$connectionName');
                // Enviar el mensaje al servidor
                mostrarDialogoAutenticacion();
                connectToWebSocket();
                importarListaMensajes();
              },
              child: const Text('Connectar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (estado == 'Conectado') {
                  String messageText = messageController.text;
                  if (messageText.isNotEmpty) {
                    bool isDuplicate =
                        messages.any((message) => message.text == messageText);

                    if (!isDuplicate) {
                      Message newMessage =
                          Message(text: messageText, timestamp: DateTime.now());
                      setState(() {
                        messages.add(newMessage);
                        messages
                            .sort((a, b) => b.timestamp.compareTo(a.timestamp));
                      });
                      channel.sink.add(messageText);
                      escribirMensajeEnArchivo(newMessage);
                    }
                  }
                }
              },
              child: const Text('Enviar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (estado == 'Conectado') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessageListScreen(
                          messages: messages, channel: channel),
                    ),
                  );
                }
              },
              child: const Text('Lista de Mensajes'),
            ),
            const SizedBox(height: 20),
            Text('Conexiones móviles: $mobileConnections'),
            Text('Conexiones de escritorio: $desktopConnections'),
            Text('Estado: $estado'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    estado = 'Desconectado';
    channel.sink.close();
    super.dispose();
  }

  void connectToWebSocket() {
    channel.stream.listen(
      (message) {
        estado = 'Conectado';
        Map<String, dynamic> data = json.decode(message);

        if (data["type"] == "connection_count") {
          setState(() {
            mobileConnections = data["mobile_connections"];
            desktopConnections = data["desktop_connections"];
          });
        }
      },
      onDone: () {
        // La conexión WebSocket se cerró de forma normal
        estado = 'Desconectado';
        setState(() {});
      },
      onError: (error) {
        // Ocurrió un error en la conexión WebSocket
        estado = 'Desconectado';
        setState(() {});
      },
    );
  }

  void importarListaMensajes() async {
    final directorio = Directory.current;

    messages =
        await leerMensajesDesdeArchivo("${directorio.path}/messages.json");
  }

  Future<List<Message>> leerMensajesDesdeArchivo(String rutaArchivo) async {
    try {
      File archivo = File(rutaArchivo);
      if (!await archivo.exists()) {
        // El archivo no existe, retorna una lista vacía
        return [];
      }

      // Lee el contenido del archivo
      String contenido = await archivo.readAsString();

      // Decodifica el contenido JSON y crea una lista de mensajes
      List<dynamic> jsonList = jsonDecode(contenido);
      List<Message> mensajes =
          jsonList.map((json) => Message.fromJson(json)).toList();
      mensajes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return mensajes;
    } catch (e) {
      // Manejar errores según sea necesario
      print("Error al leer el archivo: $e");
      return [];
    }
  }

  Future<void> escribirMensajeEnArchivo(Message nuevoMensaje) async {
    try {
      // Obtener el directorio de documentos de la aplicación
      // Construir la ruta del archivo dentro del directorio de documentos

      final directorio = Directory.current;
      final rutaArchivo = "${directorio.path}/messages.json";
      File archivo = File(rutaArchivo);
      List<Message> mensajesExistente =
          await leerMensajesDesdeArchivo(rutaArchivo);
      mensajesExistente.add(nuevoMensaje);
      String jsonMensajes = jsonEncode(
          mensajesExistente.map((mensaje) => mensaje.toJson()).toList());

      await archivo.writeAsString(jsonMensajes);
    } catch (e) {
      // Manejar errores según sea necesario
      print("Error al escribir en el archivo: $e");
    }
  }

  void mostrarDialogoAutenticacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String usuario = '';
        String contrasenya = '';

        return AlertDialog(
          title: const Text('Autenticación'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  usuario = value;
                },
                decoration: const InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                onChanged: (value) {
                  contrasenya = value;
                },
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                channel.sink.close();
                setState(() {
                  mobileConnections = 0;
                  desktopConnections = 0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                channel.sink.add(json.encode({
                  'type': 'auth',
                  'username': usuario,
                  'password': contrasenya
                }));

                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
