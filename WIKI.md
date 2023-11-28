PROTOCOL D'ACCIONS
1. Conexión al Servidor (Raspberry Pi):

    Conexión WebSocket:
        La aplicación de Flutter establece una conexión WebSocket con la dirección IP o URL del servidor WebSocket en la Raspberry Pi.

2. Mensajes:

    Enviar Mensaje al Servidor:
        La aplicación de Flutter envía mensajes al servidor mediante la conexión WebSocket. Por ejemplo:

    dart

    import 'package:web_socket_channel/io.dart';

    final channel = IOWebSocketChannel.connect('ws://192.168.0.27:8887');

    void enviarMensajeAlServidor(String mensaje) {
      channel.sink.add('{"action": "enviar_mensaje", "message": "$mensaje"}');
    }

3. Acciones Específicas:

    Acción: "channel.sink.add(messageText)":
        La Raspberry Pi recibe mensajes identificados con la acción "channel.sink.add(messageText) desde la aplicación de Flutter. La Raspberry Pi puede procesar el contenido del mensaje, almacenarlo, realizar una acción específica, etc., basándose en el mensaje recibido.

Implementación en la Aplicación de Flutter (Cliente):
1. Establecer Conexión WebSocket:

    Crear Conexión WebSocket:
        La aplicación de Flutter utiliza una librería de WebSocket para establecer una conexión con el servidor en la Raspberry Pi.

2. Enviar Mensajes al Servidor:

    Enviar Mensajes al Servidor:
        Cuando el usuario interactúa con la interfaz de la aplicación, se crea un mensaje estructurado según el protocolo definido y se envía al servidor WebSocket.
