import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    //socketService.socket.emit(event);
    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames'),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('ServerStatus: ${socketService.serverSetatus}')],
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          dynamic obj = {'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'};
          socketService.emit('emitir-mensaje', obj);
        },
      ),
    );
  }
}
