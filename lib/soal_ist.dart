import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hara_anargya/intruksi.dart';
import 'package:hara_anargya/timebar.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String sUrlSoal =
      "https://dashboard.anargya.id/api/testonline/soal/44?page=1";
  String sUrlNext;
  String sUrlPrev;
  String token;
  int tesTime;
  int _indexAnswer = 0;
  int _index = 0;
  bool isEnabledBack = false;
  bool isEnableForward = false;
  List<bool> isSelected = [false, false, false, false, false];
  List<int> isAnswer = [0, 0, 0];
  bool visible = false;
  String intruksi;
  String soal;
  List<String> pilihan = ["", "", "", "", ""];

  void initState() {
    super.initState();
    getLocalData();
    print(_index);
  }

  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      token = prefs.getString('token');
      intruksi = prefs.getString('intruksi');
      soal = prefs.getString('contohSoal');
      pilihan = prefs.getStringList('pilihanContoh');
    });

    showDialog(
        context: context,
        builder: (context) => CustomDialog("Intruksi", intruksi));
  }

  goFirstIndex() {
    _index++;
    setState(() {});
  }

  indexPlus() {
    isAnswer[_index] = _indexAnswer;
    _index++;
    setState(() {});
  }

  indexMin() {
    isAnswer[_index] = _indexAnswer;
    _index--;
    setState(() {});
  }

  getSoal(String url) async {
    setState(() {
      visible = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      print(url);
      var res = await http
          .get(url + "&perpage=1", headers: {'Authorization': 'Bearer $token'});

      var response = json.decode(res.body);
      soal = response['data'][0]['pertanyaan'];
      _index = response['current_page'];
      sUrlNext = response['next_page_url'];
      sUrlPrev = response['prev_page_url'];
      print("INIURLNEXT");
      print(response['next_page_url']);
      print("INIURLBACK");
      print(response['prev_page_url']);
      for (int i = 0;
          i < response['data'][0]['pilihan']['pilihan'].length;
          i++) {
        pilihan[i] = response['data'][0]['pilihan']['pilihan'][i]['jawaban'];
      }

      if (res.statusCode == 200) {
        setState(() {
          visible = false;
        });
      }
    } catch (e) {}
  }

  // void hitungNew() {
  //   TimeState().hitung();
  // }

  @override
  Widget build(BuildContext context) {
    switch (_index) {
      default:
    }

    switch (_indexAnswer) {
      case 0:
        isSelected[0] = false;
        isSelected[1] = false;
        isSelected[2] = false;
        isSelected[3] = false;
        isSelected[4] = false;
        break;
      case 1:
        isSelected[0] = true;
        isSelected[1] = false;
        isSelected[2] = false;
        isSelected[3] = false;
        isSelected[4] = false;
        break;
      case 2:
        isSelected[0] = false;
        isSelected[1] = true;
        isSelected[2] = false;
        isSelected[3] = false;
        isSelected[4] = false;
        break;
      case 3:
        isSelected[0] = false;
        isSelected[1] = false;
        isSelected[2] = true;
        isSelected[3] = false;
        isSelected[4] = false;
        break;
      case 4:
        isSelected[0] = false;
        isSelected[1] = false;
        isSelected[2] = false;
        isSelected[3] = true;
        isSelected[4] = false;
        break;
      case 5:
        isSelected[0] = false;
        isSelected[1] = false;
        isSelected[2] = false;
        isSelected[3] = false;
        isSelected[4] = true;
        break;
      default:
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Nunito'),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff02070A),
          title: Text("Intruksi"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => CustomDialog("Intruksi", intruksi));
              },
            ),
          ],
          elevation: 0,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xff02070A), Color(0xff072E43)]),
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))),
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 25, left: 25, right: 25, top: 0),
              child: ChangeNotifierProvider<TimeState>(
                create: (context) => TimeState(100),
                child: Column(
                  children: [
                    Consumer<TimeState>(builder: (context, timeState, _) {
                      print("HALO");
                      return CustomProgressBar(200, timeState.time, 100);
                    }),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        "PERTANYAAN",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Divider(
                      color: Colors.white24,
                      thickness: 2,
                      height: 30,
                    ),
                    Container(
                      child: Text(
                        soal == null ? "Tidak ada soal" : soal,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _index == 0
                                  ? Consumer<TimeState>(
                                      builder: (context, timeState, _) =>
                                          RaisedButton(
                                            onPressed: () {
                                              getSoal(sUrlSoal);
                                              Timer.periodic(
                                                  Duration(seconds: 1),
                                                  (timer) {
                                                if (timeState.time == 0)
                                                  timer.cancel();
                                                else
                                                  timeState.time -= 1;
                                              });
                                            },
                                            child: Icon(Icons.done),
                                            color: Colors.amber,
                                          ))
                                  : Row(
                                      children: [
                                        RaisedButton(
                                          onPressed: sUrlPrev != null
                                              ? () => getSoal(sUrlPrev)
                                              : null,
                                          child: Icon(
                                            Icons.arrow_back_ios_rounded,
                                          ),
                                          padding: EdgeInsets.all(15),
                                          shape: CircleBorder(),
                                          color: Colors.amber,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        RaisedButton(
                                          onPressed: sUrlNext != null
                                              ? () => getSoal(sUrlNext)
                                              : null,
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                          ),
                                          padding: EdgeInsets.all(15),
                                          shape: CircleBorder(),
                                          color: Colors.amber,
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 25, left: 25, right: 25, top: 220),
              child: Center(
                  child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _indexAnswer = 1;
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                        side: BorderSide(
                            color: isSelected[0] ? Colors.black : Colors.amber,
                            width: 1.5)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          color:
                              isSelected[0] ? Color(0xff02070A) : Colors.white,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          pilihan[0] == "" ? "Tidak ada jawaban" : pilihan[0],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: isSelected[0]
                                  ? Colors.white
                                  : Color(0xff02070A),
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _indexAnswer = 2;
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                        side: BorderSide(
                            color: isSelected[1] ? Colors.black : Colors.amber,
                            width: 1.5)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          color:
                              isSelected[1] ? Color(0xff02070A) : Colors.white,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          pilihan[1] == "" ? "Tidak ada jawaban" : pilihan[1],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: isSelected[1]
                                  ? Colors.white
                                  : Color(0xff02070A),
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _indexAnswer = 3;
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                        side: BorderSide(
                            color: isSelected[2] ? Colors.black : Colors.amber,
                            width: 1.5)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          color:
                              isSelected[2] ? Color(0xff02070A) : Colors.white,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          pilihan[2] == "" ? "Tidak ada jawaban" : pilihan[2],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: isSelected[2]
                                  ? Colors.white
                                  : Color(0xff02070A),
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        _indexAnswer = 4;
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0),
                        side: BorderSide(
                            color: isSelected[3] ? Colors.black : Colors.amber,
                            width: 1.5)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          color:
                              isSelected[3] ? Color(0xff02070A) : Colors.white,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          pilihan[3] == "" ? "Tidak ada jawaban" : pilihan[3],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: isSelected[3]
                                  ? Colors.white
                                  : Color(0xff02070A),
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  RaisedButton(
                      onPressed: () {
                        setState(() {
                          _indexAnswer = 5;
                        });
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0),
                          side: BorderSide(
                              color:
                                  isSelected[4] ? Colors.black : Colors.amber,
                              width: 1.5)),
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                            color: isSelected[4]
                                ? Color(0xff02070A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                              minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text(
                            pilihan[4] == "" ? "Tidak ada jawaban" : pilihan[4],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isSelected[4]
                                    ? Colors.white
                                    : Color(0xff02070A),
                                fontSize: 15),
                          ),
                        ),
                      ))
                ],
              )),
            ),
            Center(
              child: Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: visible,
                  child: Container(child: CircularProgressIndicator())),
            ),
          ],
        ),
      ),
    );
  }
}
