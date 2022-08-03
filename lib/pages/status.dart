import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
   
  
  
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return  Scaffold(
      body: Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ServerStatus : ${ socketService.serverStatus}')
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          //socketService.socket.connected;  
          socketService.socket.emit('emitir-mensaje', {'nombre' : 'Flutter', 'mensaje' : 'Hola desde flutter'});

     
    
        } ,
        child: const Icon(Icons.message),
      ),
    );
  }
}