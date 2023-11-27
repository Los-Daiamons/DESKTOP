import 'package:desktop/main.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageListScreen extends StatelessWidget {
  final List<Message> messages;
  final WebSocketChannel channel;

  MessageListScreen({required this.messages, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Mensajes'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              _reenviarAlServidor(messages[index], context);
            },
            child: ListTile(
              title: Text(messages[index].text),
              subtitle: Text(
                'Enviado el: ${messages[index].timestamp.toString().substring(0, 19)}',
              ),
            ),
          );
        },
      ),
    );
  }

  void _reenviarAlServidor(Message message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar reenvío'),
          content: Text('¿Estás seguro de que quieres reenviar este mensaje?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                channel.sink.add(message.text);
                print('Mensaje reenviado al servidor: ${message.text}');
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
