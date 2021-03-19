import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LastPage extends StatefulWidget {
  @override
  _LastPageState createState() => _LastPageState();
}

class _LastPageState extends State<LastPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Nunito'),
        home: Scaffold(
          body: Stack(children: <Widget>[
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.1, 0.7],
                      colors: [Color(0xff02070A), Color(0xff072E43)]),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Terima Kasih",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Admin'),
                        subtitle: Text(
                          'Pesan',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Terimakasih Anda telah menyelesaikan tes yang diberikan, Anda dapat keluar dari aplikasi ini.',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Container(
                        child: new Material(
                          child: new InkWell(
                            splashColor: Colors.black12,
                            onTap: () {
                              SystemNavigator.pop();
                            },
                            child: new Container(
                              alignment: Alignment.center,
                              child: Text(
                                "KELUAR APLIKASI",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 70.0,
                            ),
                          ),
                          color: Colors.transparent,
                        ),
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ));
  }
}
