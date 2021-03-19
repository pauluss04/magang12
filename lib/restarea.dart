import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hara_anargya/soal_apm.dart';
import 'package:hara_anargya/soal_cfit_tiga_a.dart';
import 'package:hara_anargya/soal_cfit_tiga_b.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Restarea extends StatefulWidget {
  @override
  _RestareaState createState() => _RestareaState();
}

class _RestareaState extends State<Restarea> {
  final String sUrlNextTest =
      "https://dashboard.anargya.id/api/testonline/next-test";
  final String sUrlIntruksi =
      "https://dashboard.anargya.id/api/testonline/instruksi/";
  final String sUrlContoh =
      "https://dashboard.anargya.id/api/testonline/contoh-soal/";
  DateTime now = DateTime.now();
  Timer _timer;
  int _start = 60;
  bool visible = false;
  String token;
  int idAlatTes;
  int tesTime;
  String intruksi;
  String contohSoal;
  List<String> pilihanContoh = [];

  void initState() {
    super.initState();
    // startTimer();
    getLocalData();
  }

  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  getSoal() async {
    setState(() {
      visible = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      var res = await http
          .get(sUrlNextTest, headers: {'Authorization': 'Bearer $token'});
      var response = json.decode(res.body);

      idAlatTes = response['next']['id'];
      var time = response['next']['waktu'] * 60;
      tesTime = time.toInt();

      var resOne = await http.get(sUrlIntruksi + idAlatTes.toString(),
          headers: {'Authorization': 'Bearer $token'});
      var resTwo = await http.get(sUrlContoh + idAlatTes.toString(),
          headers: {'Authorization': 'Bearer $token'});
      var responseOne = json.decode(resOne.body);
      var responseTwo = json.decode(resTwo.body);
      if (idAlatTes == 105 || idAlatTes == 106) {
        intruksi = responseOne['isi'];
        contohSoal = '';
        pilihanContoh = [];
      } else {
        intruksi = responseOne['isi'];
        contohSoal = responseTwo[0]['pertanyaan'];
        for (int i = 0; i < responseTwo[0]['pilihan'].length; i++) {
          var con = responseTwo[0]['pilihan'][i]['jawaban'].toString();
          pilihanContoh.add(con);
        }
      }

      prefs.setString('intruksi', intruksi);
      prefs.setString('contohSoal', contohSoal);
      prefs.setStringList('pilihanContoh', pilihanContoh);
      prefs.setInt('idAlatTes', idAlatTes);
      prefs.setInt('tesTime', tesTime);

      if (resOne.statusCode == 200 && resTwo.statusCode == 200) {
        if (idAlatTes == 36 ||
            idAlatTes == 38 ||
            idAlatTes == 40 ||
            idAlatTes == 42) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return (CfitTigaA(tesTime));
          }));
        } else if (idAlatTes == 37 ||
            idAlatTes == 39 ||
            idAlatTes == 41 ||
            idAlatTes == 43) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return (CfitTigaB(tesTime));
          }));
        } else if (idAlatTes == 105 || idAlatTes == 106) {
          print(pilihanContoh);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return (Apm(tesTime));
          }));
        }
      }
    } catch (e) {
      print("error get soal " + e.toString());
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

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
                    "Halaman Jeda",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    _start.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.mail),
                        title: const Text('Kotak Pesan'),
                        subtitle: Text(
                          'Admin Tes',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Tampilan ini adalah tampilan halaman jeda. Di halaman ini Anda dapat menghubungi admin terkait kendala yang muncul.',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Perform some action
                            },
                            child: const Text('Pesan Masuk'),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          TextButton(
                            onPressed: () {
                              // Perform some action
                            },
                            child: const Text('Pesan Terkirim'),
                          ),
                        ],
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white60,
                              suffixIcon: Icon(Icons.edit,
                                  size: 15, color: Colors.black54),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      (BorderRadius.all(Radius.circular(8.0))),
                                  borderSide:
                                      BorderSide(color: Colors.black12)),
                              contentPadding: EdgeInsets.only(
                                  bottom: 10.0, left: 10.0, right: 10.0),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide:
                                      BorderSide(color: Colors.black38)),
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        height: 90,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black12,
                      ),
                      Container(
                        child: new Material(
                          child: new InkWell(
                            splashColor: Colors.black12,
                            onTap: () {
                              getSoal();
                            },
                            child: new Container(
                              alignment: Alignment.center,
                              child: Text(
                                "LANJUT TEST",
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
