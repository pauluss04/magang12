import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hara_anargya/login_page.dart';
import 'package:hara_anargya/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class LauncherPage extends StatefulWidget {
  @override
  _LauncherPageState createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  String sUrl = "https://dashboard.anargya.id/api/";
  TextEditingController namaEventController = new TextEditingController();
  bool alertDialog = false;
  bool isChanged = false;
  bool visible = false;
  int event_id;
  String message = "";

  @override
  void initState() {
    super.initState();
    startLaunching();
  }

  _cekLogin() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      visible = true;
    });

    final prefs = await SharedPreferences.getInstance();

    var res = await http.get(sUrl + namaEventController.text);

    var response = json.decode(res.body);

    if (response['status'] == true) {
      print("Berhasil");
      event_id = response['data']['id'];
      prefs.setInt('event_id', event_id);
      setState(() {
        visible = false;
      });
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (_) {
        return Login();
      }));
    } else {
      setState(() {
        visible = false;
      });
      message = response['message'];
      var duration = const Duration(milliseconds: 3000);
      return new Timer(duration, () {
        setState(() {
          message = "";
        });
      });
    }
  }

  startLaunching() async {
    final prefs = await SharedPreferences.getInstance();

    bool islogin = false;
    if (prefs.getString('token') != null) {
      islogin = true;
    }

    var duration = const Duration(milliseconds: 1600);
    return new Timer(duration, () {
      print("Masokkk");
      islogin == true
          ? Navigator.of(context)
              .pushReplacement(new MaterialPageRoute(builder: (_) {
              return MainPage();
            }))
          : setState(() {
              alertDialog = true;
            });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              alertDialog == false
                  ? Center(
                      child: Stack(
                        children: [
                          Container(
                            child: new Image.asset(
                              "assets/images/logo.png",
                              height: MediaQuery.of(context).size.width * 0.5,
                              width: MediaQuery.of(context).size.width * 0.5,
                            ),
                          ),
                          Shimmer.fromColors(
                            baseColor: Color(0xff02070A),
                            highlightColor: Color(0x00000000),
                            child: new Image.asset(
                              "assets/images/logo.png",
                              height: MediaQuery.of(context).size.width * 0.5,
                              width: MediaQuery.of(context).size.width * 0.5,
                            ),
                          )
                        ],
                      ),
                    )
                  : AlertDialog(
                      title: Text('Masukkan Nama Event'),
                      content: TextField(
                        onChanged: (value) {
                          setState(() {
                            var valueText = value;
                          });
                        },
                        controller: namaEventController,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          color: Color(0xFFDDB258),
                          textColor: Colors.white,
                          child: Text('OK'),
                          onPressed: () {
                            setState(() {
                              _cekLogin();
                            });
                          },
                        ),
                      ],
                    ),
              Text(message, style: TextStyle(color: Colors.red, fontSize: 18))
            ],
          )),
      Center(
        child: Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: visible,
            child: Container(
              child: SpinKitFadingCube(
                color: Colors.amber,
              ),
            )),
      ),
    ]));
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Masukkan Nama Event'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  var valueText = value;
                });
              },
              controller: namaEventController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            actions: <Widget>[
              FlatButton(
                color: Color(0xFFDDB258),
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    _cekLogin();
                  });
                },
              ),
            ],
          );
        });
  }
}
