import 'package:desktop/main.dart';
import 'package:flutter/material.dart';

class MessageListScreen extends StatelessWidget {
  final List<Message> messages;

  MessageListScreen({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Mensajes'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(messages[index].text),
            subtitle: Text(
              'Enviado el: ${messages[index].timestamp.toString()}',
            ),
          );
        },
      ),
    );
  }
}
