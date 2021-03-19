import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter/material.dart';
import 'package:hara_anargya/intruksi.dart';
import 'package:hara_anargya/last_page.dart';
import 'package:hara_anargya/restarea.dart';
import 'package:hara_anargya/timebar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Raven extends StatefulWidget {
  final int waktuTes;
  Raven(this.waktuTes);
  @override
  _RavenState createState() => _RavenState();
}

class _RavenState extends State<Raven> {
  String sUrlSoal = "https://dashboard.anargya.id/api/testonline/soal/";
  String sUrlStore = "https://dashboard.anargya.id/api/testonline/soal/";
  String baseUrl = "https://dashboard.anargya.id/api/testonline/";
  int totalPage;
  String sUrlNext;
  String sUrlPrev;
  String token;
  String eventId;
  String username;
  int idAlatTes;
  int cameraTime;
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
  List<String> pilihan = ["", "", "", "", "", ""];
  List<String> _listPilihan = [];
  List<String> _idSoal = [];
  bool alertStart = false;
  bool countTimer = false;
  bool tutupTime = false;
  ScrollController _scrollController = new ScrollController();
  CameraController controller;
  String base64;
  String fileName;
  File _fileImage;
  int ceked = 0;

  @override
  void initState() {
    super.initState();
    disableCapture();
    getLocalData();
    // takePicture();
    delayTake();
  }

  @override
  void dispose() {
    countTimer = false;
    

    super.dispose();
  }

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    await controller.initialize();
  }

  _saveBase() async {
    _fileImage = await takePicture();

    List<int> imageBytes = _fileImage.readAsBytesSync();

    String _img64 = base64Encode(imageBytes);
    base64 = _img64;
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('base64', base64);
    // print("SAVEBASE");
  }

  delayTake() async {
    // print(eventId);
    // print(username);
    _fileImage = await takePicture();
    fileName = _fileImage.path.split('/').last;
    // print(fileName);
    // print(_fileImage);
    FormData formData = new FormData.fromMap({
      "LwsCamLib":
          await MultipartFile.fromFile(_fileImage.path, filename: fileName),
    });
    Dio dio = new Dio();
    var response = await dio.post(
      '${baseUrl}upload-photo/event_$eventId/$username/more',
      data: formData,
    );
    // print(response);
    var duration = const Duration(seconds: 30);
    setState(() {});
    return new Timer(duration, () {
      delayTake();
    });
  }

  takePicture() async {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Profile_Camera';
    await new Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${DateTime.now()}.jpg';

    try {
      await controller.takePicture(filePath);
      ceked++;
      // print("Take " + ceked.toString());
      return File(filePath);
    } catch (e) {
      // print("gagal take " + e.toString());
      return delayTake();
    }
  }

  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  scrollControl() {
    _scrollController =
        new ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
  }

  saveJawaban() async {
    setState(() {
      visible = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> paket = {};

    for (var i = 0; i < _listPilihan.length; i++) {
      paket.addAll({_idSoal[i]: _listPilihan[i]});
    }
    var paketEncode = json.encode(paket);

    try {
      // print(sUrlStore + idAlatTes.toString() + "/store-jawaban");
      var res = await http
          .post(sUrlStore + idAlatTes.toString() + "/store-jawaban", body: {
        "jawaban": paketEncode.toString(),
        "event_id": prefs.getInt("event_id").toString()
      }, headers: {
        'Authorization': 'Bearer $token'
      });

      var response = json.decode(res.body);
      // print(response);
      setState(() {
        visible = false;
        tutupTime = true;
      });

      if (response['next']['id'] == 999) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return Restarea();
        }));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return LastPage();
        }));
      }
    } catch (e) {
      // print("Gagal masuk restarea " + e);
    }
  }

  ceklocalJawab() {
    if (_listPilihan[_index - 1] == "a") {
      _indexAnswer = 1;
    }
    if (_listPilihan[_index - 1] == "b") {
      _indexAnswer = 2;
    }
    if (_listPilihan[_index - 1] == "c") {
      _indexAnswer = 3;
    }
    if (_listPilihan[_index - 1] == "d") {
      _indexAnswer = 4;
    }
    if (_listPilihan[_index - 1] == "e") {
      _indexAnswer = 5;
    }
    if (_listPilihan[_index - 1] == "") {
      _indexAnswer = 0;
    }
  }

  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      username = prefs.getString('username');
      idAlatTes = prefs.getInt('idAlatTes');
      eventId = prefs.getInt('event_id').toString();
      cameraTime = prefs.getInt('cameraTime');
      tesTime = prefs.getInt('tesTime');
      if (idAlatTes == 130) {
        intruksi = prefs.getString('intruksi');
      } else {
        intruksi = 'Kerjakan seperti pada instruksi sebelumnya!';
      }
      soal = prefs.getString('contohSoal');
      pilihan = prefs.getStringList('pilihanContoh');
      print(pilihan);
      print(soal);
      // print(eventId);
    });

    showDialog(
        context: context,
        builder: (context) => CustomDialog("Intruksi", intruksi));
  }

  getSoal(String url) async {
    setState(() {
      visible = true;
    });
    if (_index == 0) {
      url = url + idAlatTes.toString() + "?page=1&perpage=1";
    }

    try {
      // print(url);
      var res = await http
          .get(url + "&perpage=1", headers: {'Authorization': 'Bearer $token'});
      var response = json.decode(res.body);

      if (_index == 0) {
        totalPage = response['total'];
        _listPilihan = List<String>.generate(totalPage, (i) => "");
        _idSoal = List<String>.generate(totalPage, (i) => "");
      }
      soal = response['data'][0]['pertanyaan'];
      _index = response['current_page'];
      sUrlNext = response['next_page_url'];
      sUrlPrev = response['prev_page_url'];
      int id = response['data'][0]['id'];

      for (int i = 0; i < response['data'][0]['pilihan'].length; i++) {
        pilihan[i] = response['data'][0]['pilihan'][i]['jawaban'];
      }

      print(_listPilihan);
      if (res.statusCode == 200) {
        setState(() {
          ceklocalJawab();
          _idSoal[_index - 1] = id.toString();
          visible = false;
          countTimer = true;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
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
        body: FutureBuilder(
          future: initializeCamera(),
          builder: (_, snapshot) => Stack(children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    height: 200,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff02070A), Color(0xff072E43)]),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30))),
                    height: MediaQuery.of(context).size.height * 0.08,
                  ),
                  _index == 0
                      ? Container(
                          child: Center(
                          child: Text(
                            "SILAHKAN MEMULAI TEST",
                            style: TextStyle(fontSize: 15),
                          ),
                        ))
                      : 
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 100, left: 25, right: 25, top: 220),
                    child: Center(
                        child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: <Widget>[
                          MaterialButton(
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.grey,
                            elevation: 8.0,
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: _indexAnswer == 1
                                    ? Colors.grey
                                    : Colors.white,
                                image: DecorationImage(
                                    image: pilihan[0] != ""
                                        ? NetworkImage(pilihan[0])
                                        : NetworkImage(""),
                                    fit: BoxFit.contain),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              _index != 0
                                  ? setState(() {
                                      _listPilihan[_index - 1] = "a";
                                      _indexAnswer = 1;
                                    })
                                  : setState(() {
                                      _indexAnswer = 1;
                                    });
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          MaterialButton(
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.grey,
                            elevation: 8.0,
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: _indexAnswer == 2
                                    ? Colors.grey
                                    : Colors.white,
                                image: DecorationImage(
                                    image: pilihan[1] != ""
                                        ? NetworkImage(pilihan[1])
                                        : NetworkImage(""),
                                    fit: BoxFit.contain),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              _index != 0
                                  ? setState(() {
                                      _listPilihan[_index - 1] = "b";
                                      _indexAnswer = 2;
                                    })
                                  : setState(() {
                                      _indexAnswer = 2;
                                    });
                            },
                          ),
                          SizedBox(height: 10),
                          MaterialButton(
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.grey,
                            elevation: 8.0,
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: _indexAnswer == 3
                                    ? Colors.grey
                                    : Colors.white,
                                image: DecorationImage(
                                    image: pilihan[2] != ""
                                        ? NetworkImage(pilihan[2])
                                        : NetworkImage(""),
                                    fit: BoxFit.contain),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              _index != 0
                                  ? setState(() {
                                      _listPilihan[_index - 1] = "c";
                                      _indexAnswer = 3;
                                    })
                                  : setState(() {
                                      _indexAnswer = 3;
                                    });
                            },
                          ),
                          SizedBox(height: 10),
                          MaterialButton(
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.grey,
                            elevation: 8.0,
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: _indexAnswer == 4
                                    ? Colors.grey
                                    : Colors.white,
                                image: DecorationImage(
                                    image: pilihan[3] != ""
                                        ? NetworkImage(pilihan[3])
                                        : NetworkImage(""),
                                    fit: BoxFit.contain),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              _index != 0
                                  ? setState(() {
                                      _listPilihan[_index - 1] = "d";
                                      _indexAnswer = 4;
                                    })
                                  : setState(() {
                                      _indexAnswer = 4;
                                    });
                            },
                          ),
                          SizedBox(height: 10),
                          MaterialButton(
                            padding: EdgeInsets.all(8.0),
                            splashColor: Colors.grey,
                            elevation: 8.0,
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: _indexAnswer == 5
                                    ? Colors.grey
                                    : Colors.white,
                                image: DecorationImage(
                                    image: pilihan[4] != ""
                                        ? NetworkImage(pilihan[4])
                                        : NetworkImage(""),
                                    fit: BoxFit.contain),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                            onPressed: () {
                              _index != 0
                                  ? setState(() {
                                      _listPilihan[_index - 1] = "e";
                                      _indexAnswer = 5;
                                    })
                                  : setState(() {
                                      _indexAnswer = 5;
                                    });
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    )),
                  ),
                  Stack(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                          bottom: 25, left: 0, right: 0, top: 0),
                      child: ChangeNotifierProvider<TimeState>(
                        create: (context) => TimeState(widget.waktuTes),
                        child: Column(
                          children: [
                            Consumer<TimeState>(
                                builder: (context, timeState, _) {
                              // print("HALO");
                              return new CustomProgressBar(
                                  200, timeState.time, widget.waktuTes);
                            }),
                            SizedBox(
                               height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Container(
                              child: Text(
                                _index == 0
                                    ? ""
                                    : "SOAL " + "$_index",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                             height: MediaQuery.of(context).size.height * 0.14,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: soal == null
                                          ? NetworkImage("")
                                          : imageCek(soal),
                                      fit: BoxFit.contain)),
                            ),
                            alertStart == true
                                ? AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    title: Text("Perhatian"),
                                    content: Text(
                                        "Apa Anda yakin ingin memulai test ini?"),
                                    actions: [
                                      TextButton(
                                        child: Text("Tidak"),
                                        onPressed: () {
                                          setState(() {
                                            alertStart = false;
                                          });
                                        },
                                      ),
                                      Consumer<TimeState>(
                                          builder: (context, timeState, _) =>
                                              TextButton(
                                                child: Text("Iya"),
                                                onPressed: () {
                                                  setState(() {
                                                    alertStart = false;
                                                  });
                                                  getSoal(sUrlSoal);
                                                  Timer.periodic(
                                                      Duration(seconds: 1),
                                                      (timer) {
                                                    if (timeState.time == 0)
                                                      saveJawaban();
                                                    else if (countTimer ==
                                                            true &&
                                                        tutupTime == false)
                                                      timeState.time -= 1;
                                                    else if (tutupTime == true)
                                                      timer.cancel();
                                                  });
                                                },
                                              ))
                                    ],
                                  )
                                : Container(),
                            Expanded(
                              child: Container(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      _index == 0
                                          ? RaisedButton(
                                              onPressed: () {
                                                setState(() {
                                                  alertStart = true;
                                                });
                                              },
                                              child: Text("Mulai Test"),
                                              color: Colors.amber,
                                            )
                                          : _index < totalPage
                                              ? Row(
                                                  children: [
                                                    RaisedButton(
                                                      onPressed: sUrlPrev !=
                                                              null
                                                          ? () =>
                                                              getSoal(sUrlPrev)
                                                          : null,
                                                      child: Icon(
                                                        Icons
                                                            .arrow_back_ios_rounded,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      shape: CircleBorder(),
                                                      color: Colors.amber,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    RaisedButton(
                                                      onPressed: sUrlNext !=
                                                              null
                                                          ? () =>
                                                              getSoal(sUrlNext)
                                                          : null,
                                                      child: Icon(
                                                        Icons
                                                            .arrow_forward_ios_rounded,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      shape: CircleBorder(),
                                                      color: Colors.amber,
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    RaisedButton(
                                                      onPressed: sUrlPrev !=
                                                              null
                                                          ? () =>
                                                              getSoal(sUrlPrev)
                                                          : null,
                                                      child: Icon(
                                                        Icons
                                                            .arrow_back_ios_rounded,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      shape: CircleBorder(),
                                                      color: Colors.amber,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    RaisedButton(
                                                      onPressed: () {
                                                        _showAlertDialog(
                                                            context);
                                                      },
                                                      child: Text("SELESAI"),
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      color: Colors.amber,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          30),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          30))),
                                                    ),
                                                  ],
                                                )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ]),
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
                ],
              ),
            ),
            snapshot.connectionState == ConnectionState.done
                ? Center(
                    child: Container(
                      height: 0,
                      width: 0,
                      child: CameraPreview(controller),
                    ),
                  )
                : Center(
                    child: Container(
                      height: 0,
                      width: 0,
                      color: Colors.blue,
                    ),
                  ),
          ]),
        ),
      ),
    );
  }

  _showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Tidak"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Iya"),
      onPressed: () {
        Navigator.pop(context);
        saveJawaban();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text("Perhatian"),
      content: Text("Apa anda yakin ingin mengakhiri sesi ini?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  NetworkImage imageCek(String url) {
    try {
      print(url);
      return NetworkImage(url);
      
    } catch (e) {
      // print("tes");
      // print(e);
      return null;
    }
  }
}
