import 'package:flutter/material.dart';
import 'package:helloflutter/util.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _msg;

  void _getMsg() {
    Util.httpGet(Util.url("136570490")).then((value) {
      setState(() {
        var matchs = value.toList();
        int win = 0;
        for (var match in matchs) {
          if (iswin(match)) win++;
        }
        int lose = matchs.length - win;
        double winRate = win / matchs.length;
        _msg = "总场次:" +
            matchs.length.toString() +
            " | 胜场:" +
            win.toString() +
            "败场:" +
            lose.toString() +
            "胜率:" +
            winRate.toStringAsFixed(3);
      });
    });
  }

  bool iswin(Map<String, dynamic> match) {
    var playerSlot = match['player_slot'];
    var radiantWin = match['radiant_win'];
    var inRadiant = playerSlot < 127;
    return inRadiant == radiantWin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_msg',
            ),
            MaterialButton(
              color: Colors.blue,
              child: Text('查询'),
              onPressed: _getMsg,
            ),
          ],
        ),
      ),
    );
  }
}
