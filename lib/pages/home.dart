import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
   
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band (id:  '1' , name: 'Metallica', votes: 5),
    // Band (id:  '2' , name: 'AC/DC', votes: 4),
    // Band (id:  '3' , name: 'Ramstein', votes: 3),
    // Band (id:  '4' , name: 'Queen', votes: 5),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context , listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);    
    super.initState();
  }

  _handleActiveBands( dynamic payload) {
      this.bands = (payload as List).map((banda) => Band.fromMap(banda)).toList();
      setState(() {});
  }

  @override
  void dispose() {
     final socketService = Provider.of<SocketService>(context , listen: false);
     socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final serverStatus = Provider.of<SocketService>(context).serverStatus;
    return  Scaffold(
      appBar: AppBar(
      title: const Text('Band Names', style:  TextStyle(color: Colors.black87),),
      backgroundColor: Colors.white,
      elevation: 1,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: (serverStatus == ServerStatus.Online)  
          ? Icon(Icons.check_circle, color : Colors.blue[300])
          : const Icon(Icons.offline_bolt, color : Colors.red),
        )
      ],
      ),
      body: Column(
        children : [
          _showGraph(),
           Expanded(
             child: ListView.builder(
                   itemCount: bands.length,
                   itemBuilder: ( context, int index) =>  _bandTile(bands[index])
                 ),
           ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand ,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context , listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => socketService.socket.emit('delete-band', {'id': band.id}),            
      background: Container( 
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),),
        ),
      ),
      child: ListTile(
            leading: CircleAvatar (
              backgroundColor: Colors.blue[100],
              child: Text(band.name.substring(0,2)),
            ),
            title: Text(band.name),
            trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20),),
            onTap: () => socketService.socket.emit('vote-band', { 'id' : band.id })     
          ),
    );
  }




  addNewBand() {
    final textController = TextEditingController();
  if (Platform.isAndroid)
  {
    showDialog(
      context: context, 
      builder: (_)  => 
         AlertDialog(
          title: const Text('New band name:'),
          content:  TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
              child: const Text('Add')
            )
          ],
        ),
      
    );
  }

  showCupertinoDialog(){

  }
  }

  void addBandToList(String name){
    if(name.length> 1){
      
      final socketService = Provider.of<SocketService>(context , listen: false);

      socketService.socket.emit('add-band' , {'name' : name});
    }
    

    Navigator.pop(context);
  }


//Mostrar Gráfica
  Widget _showGraph(){
    Map<String, double> dataMap = {};
    bands.forEach((banda) {
      dataMap.putIfAbsent(banda.name, () => banda.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[50]! , 
      Colors.blue[200]! , 
      Colors.pink[50]! , 
      Colors.pink[200]! , 
      Colors.yellow[50]! , 
      Colors.yellow[200]! , 
    ];

    return dataMap.isNotEmpty ? Container(
          width: double.infinity,
          height: 200,
          child: PieChart(
          dataMap: dataMap,
          animationDuration: const Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,            
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
            
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        )
      ) : LinearProgressIndicator();
  }
}