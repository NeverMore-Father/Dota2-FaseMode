import 'package:flutter/material.dart';
import 'package:helloflutter/util.dart';
import 'package:helloflutter/winRateBean.dart';
import 'myHomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xps',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.red),
      // home: MyHomePage(title: 'Dota2'),
      home: HomePage(
        title: "test",
        playerId: "136570490",
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.playerId}) : super(key: key);

  final String title;
  final String playerId;

  @override
  State<StatefulWidget> createState() {
    print("id = " + playerId);
    var pageState = _HomePageState(playerId: playerId);
    pageState.refresh();
    return pageState;
  }
}

class _HomePageState extends State<HomePage> {
  _HomePageState({this.playerId});
  String playerId;
  List<WinRateBean> list = List<WinRateBean>();
  String name;
  bool iswin(Map<String, dynamic> match) {
    var playerSlot = match['player_slot'];
    var radiantWin = match['radiant_win'];
    var inRadiant = playerSlot < 127;
    return inRadiant == radiantWin;
  }

  WinRateBean getBean(int count, List<dynamic> matchs) {
    int win = 0;

    for (var i = 0; i < count; i++) {
      var match = matchs[i];
      if (iswin(match)) win++;
    }

    var winRateBean = WinRateBean();
    winRateBean.all = count;
    winRateBean.win = win;
    winRateBean.title = "";
    return winRateBean;
  }

  void refresh() {
    print("刷新");

    Util.httpGet(Util.playerInfoUrl(playerId)).then((value) {
      setState(() {
        name = (value["profile"]["personaname"]);
        Util.testurl = value["profile"]["avatarfull"];
      });
    });

    Util.httpGet(Util.url(playerId)).then((value) {
      setState(() {
        try {
          var matchs = value.toList();
          var m1 = getBean(matchs.length, matchs);
          var m2 = getBean(100, matchs);
          var m3 = getBean(50, matchs);
          var m4 = getBean(20, matchs);
          list = List();
          list.add(m1);
          list.add(m2);
          list.add(m3);
          list.add(m4);
        } catch (e) {
          print(e);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("构建" + widget.playerId);
    return Scaffold(
        backgroundColor: Util.hexColor(0xdedede),
        // appBar: AppBar(title: Text(widget.title)),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
              height: 250,
              width: double.maxFinite,
              color: Colors.black87,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Image.network(
                    Util.testurl,
                    width: 150,
                    height: 150,
                  ),
                  Positioned(
                    bottom: 5,
                    child: Text(
                      name,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: list == null ? 0 : list.length,
                  itemBuilder: (BuildContext context, int index) {
                    var bean = list[index];
                    print(bean.title);
                    return WinStatisticsContainer(
                      all: bean.all,
                      win: bean.win,
                      lose: bean.all - bean.win,
                      timeTitle: bean.title,
                    );
                  },
                ),
              ),
            )
          ],
        ));
  }
}

class WinStatisticsContainer extends Container {
  static double winRate(int win, int all) {
    return (win / all);
  }

  WinStatisticsContainer({int all, int win, int lose, String timeTitle})
      : super(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.0),
          ),
          margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          child: Column(
            children: <Widget>[
              Text(timeTitle == null ? "" : timeTitle),
              SizedBox(
                height: 5,
              ),
              Divider(
                color: Colors.black12,
                height: 1,
              ),
              WinContainer(
                all: all,
                win: win,
                lose: lose,
              ),
              Divider(
                color: Colors.black12,
                height: 1,
              ),
              WinProgressIndicator(
                v: winRate(win, all),
              ),
            ],
          ),
        );
}

class WinContainer extends Container {
  WinContainer({int all, int win, int lose})
      : super(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MathchText(
                count: all.toString(),
                dec: "场次",
              ),
              Container(
                width: 1,
                color: Colors.black12,
                height: 30,
              ),
              MathchText(
                count: win.toString(),
                dec: "胜场",
              ),
              Container(
                width: 1,
                color: Colors.black12,
                height: 30,
              ),
              MathchText(
                count: lose.toString(),
                dec: "败场",
              ),
            ],
          ),
        );
}

class WinProgressIndicator extends Container {
  WinProgressIndicator({double v})
      : super(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                        height: 1,
                        child: LinearProgressIndicator(
                          value: v,
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black87),
                        ))),
                Container(
                  child: Text((v * 100).toStringAsFixed(2) + "%",
                      style: TextStyle(
                        fontSize: 12,
                      )),
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                )
              ],
            ));
}

class MathchText extends Container {
  MathchText({String dec, String count})
      : super(
          child: Column(
            children: <Widget>[
              Text(
                count,
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                dec,
                style: TextStyle(fontSize: 10, color: Util.hexColor(0xdedede)),
              )
            ],
          ),
        );
}
