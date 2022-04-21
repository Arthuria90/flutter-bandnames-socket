import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  // evitar escuchar info cuando ya no se necesita
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverSetatus == ServerStatus.Online)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) => _bandTile(bands[index])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: addNewBand, elevation: 1),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
          padding: EdgeInsets.only(left: 12.0),
          color: Colors.red,
          child: Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('Delete Band', style: TextStyle(color: Colors.white)))),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name!.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name!),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      // Android
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New band name: '),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                    onPressed: () => addBandToList(textController.text),
                    child: Text('Add'),
                    elevation: 5,
                    textColor: Colors.blue,
                  )
                ],
              ));
    }
    if (Platform.isIOS) {
      // IOS
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text('New band name: '),
                content: CupertinoTextField(
                  controller: textController,
                ),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add'),
                    onPressed: () => addBandToList(textController.text),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ));
    }
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      //Podemos agregar
      socketService.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue.shade50,
      Colors.blue.shade200,
      Colors.pink.shade50,
      Colors.pink.shade200,
      Colors.yellow.shade50,
      Colors.yellow.shade200,
    ];
    return Container(
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
        ));
  }
}
