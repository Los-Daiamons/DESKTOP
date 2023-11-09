import 'package:flutter/material.dart';

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
                // Aquí puedes manejar la lógica para enviar el mensaje a la IP proporcionada.
                String message = messageController.text;
                String ipAddress = ipController.text;
                // ¡Haz lo que necesites con el mensaje y la IP!
              },
              child: Text('Connectar'),
            ),
          ],
        ),
      ),
    );
  }
}
