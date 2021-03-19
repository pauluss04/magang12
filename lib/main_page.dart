import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hara_anargya/camera_page.dart';
import 'package:hara_anargya/detail_image.dart';
import 'package:hara_anargya/soal_apm.dart';
import 'package:hara_anargya/soal_cfit_tiga_a.dart';
import 'package:hara_anargya/soal_cfit_tiga_b.dart';
import 'package:hara_anargya/soal_ist.dart';
import 'package:hara_anargya/login_page.dart';
import 'package:hara_anargya/soal_raven.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainPage extends StatefulWidget {
  _MainPageState myMainPageState = new _MainPageState();
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final String sUrlSave =
      "https://dashboard.anargya.id/api/testonline/save-profile";
  final String sUrlNextTest =
      "https://dashboard.anargya.id/api/testonline/next-test";
  final String sUrlIntruksi =
      "https://dashboard.anargya.id/api/testonline/instruksi/";
  final String sUrlContoh =
      "https://dashboard.anargya.id/api/testonline/contoh-soal/";
  String baseImage;
  String intruksi;
  String contohSoal;
  String token;
  int idAlatTes;
  int tesTime;

  List<String> pilihanContoh = [];
  List<String> typeList = [];
  List<String> attList = [];
  List<String> labList = [];
  List<String> hasList = [];
  List<String> dropdownSatu = [];
  List<String> dropdownDua = [];
  List<String> dropdownTiga = [];
  List<String> radioSatu = [];
  List<String> radioDua = [];
  List<String> radioTiga = [];
  List<String> radioEmpat = [];
  List<Widget> listWidget = [];
  String resulltt;
  File imageFile;
  Uint8List imageTemp;
  int indexDropdown = 0;
  int indexRadio = 0;
  bool listBuilder = false;
  bool visible = false;
  List<TextEditingController> conText = [];
  List<dynamic> tempPop = [];

  void initState() {
    super.initState();
    getLocalData();
  }

  void getWidget() {
    for (int i = 0; i < typeList.length; i++) {
      if (typeList[i] == "text") {
        hasList.add(conText[i].text);
        listWidget.add(TypeText(labList[i], conText[i]));
      } else if (typeList[i] == "date") {
        hasList.add(conText[i].text);
        listWidget.add(TypeDate(labList[i], conText[i]));
      } else if (typeList[i] == "dropdown" && indexDropdown == 0) {
        hasList.add(conText[i].text);
        listWidget.add(TypeDropdown(labList[i], dropdownSatu, conText[i]));

        indexDropdown++;
      } else if (typeList[i] == "dropdown" && indexDropdown == 1) {
        hasList.add(conText[i].text);
        listWidget.add(TypeDropdown(labList[i], dropdownDua, conText[i]));

        indexDropdown++;
      } else if (typeList[i] == "dropdown" && indexDropdown == 2) {
        hasList.add(conText[i].text);
        listWidget.add(TypeDropdown(labList[i], dropdownTiga, conText[i]));

        indexDropdown++;
      } else if (typeList[i] == "radio" && indexRadio == 0) {
        hasList.add(conText[i].text);
        listWidget.add(TypeRadio(labList[i], radioSatu, conText[i]));

        indexRadio++;
      } else if (typeList[i] == "radio" && indexRadio == 1) {
        hasList.add(conText[i].text);
        listWidget.add(TypeRadio(labList[i], radioDua, conText[i]));

        indexRadio++;
      } else if (typeList[i] == "radio" && indexRadio == 2) {
        hasList.add(conText[i].text);
        listWidget.add(TypeRadio(labList[i], radioTiga, conText[i]));

        indexRadio++;
      } else if (typeList[i] == "radio" && indexRadio == 3) {
        hasList.add(conText[i].text);
        listWidget.add(TypeRadio(labList[i], radioEmpat, conText[i]));

        indexRadio++;
      }
    }
  }

  getLocalImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      baseImage = prefs.getString('base64');
    });
  }

  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
      idAlatTes = prefs.getInt('idAlatTes');
      tesTime = prefs.getInt('tesTime');
      baseImage = prefs.getString('base64');
      typeList = prefs.getStringList('typeBioList');
      attList = prefs.getStringList('attBioList');
      labList = prefs.getStringList('labBioList');
      dropdownSatu = prefs.getStringList('dropSatu');
      dropdownDua = prefs.getStringList('dropDua');
      dropdownTiga = prefs.getStringList('dropTiga');
      radioSatu = prefs.getStringList('radioSatu');
      radioDua = prefs.getStringList('radioDua');
      radioTiga = prefs.getStringList('radioTiga');
      radioEmpat = prefs.getStringList('radioEmpat');
      conText = List.generate(typeList.length, (i) => TextEditingController());
      if (baseImage == '' || baseImage == null) {
        imageTemp = imageTemp;
      } else {
        imageTemp = Base64Decoder().convert(baseImage);
      }

      getWidget();
      print(baseImage);
    });
  }

  saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> paket = {};

    for (var i = 0; i < attList.length; i++) {
      paket.addAll({attList[i]: conText[i].text});
    }
    paket.addAll({'foto': baseImage});
    print(paket);
    var _list = paket.values.toList();
    if (_list.contains("") || _list.contains(null)) {
      _showAlertDialog(context, "Data profil tidak boleh kosong!");
    } else {
      try {
        var response = await http.post(sUrlSave,
            body: {"general": paket.toString(), "custom": ""},
            headers: {'Authorization': 'Bearer $token'});

        var re = json.decode(response.body);
        if (response.statusCode == 200) {
          print(re);
        }
        getSoal();
      } catch (e) {
        print("Error jir");
      }
    }
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
        } else if (idAlatTes == 130) {
          print(pilihanContoh);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return (Raven(tesTime));
          }));
        } 
      }
    } catch (e) {
      print("error get soal " + e.toString());
    }
  }

  logOut() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return Login();
    }));
    setState(() {});
  }

  _showAlertDialog(BuildContext context, String err) {
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.pop(context);
        });
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text(err),
      actions: [okButton],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Nunito'),
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 230,
                    child: Stack(
                      children: <Widget>[
                        Container(),
                        ClipPath(
                          clipper: MyCustomClipper(),
                          child: Container(
                            height: 300,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                  Color(0xff02070A),
                                  Color(0xff072E43)
                                ])),
                          ),
                        ),
                        Align(
                          alignment: Alignment(0, 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 55,
                                child: Hero(
                                  tag: "pp",
                                  child: GestureDetector(
                                    onTap: () {
                                      print(conText[2].text);
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return DetailImage();
                                      }));
                                      setState(() {});
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black38,
                                      backgroundImage: (imageTemp != null)
                                          ? MemoryImage(imageTemp)
                                          : AssetImage(
                                              'assets/images/ProfilePict.png'),
                                      radius: 50.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              "Registrasi",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 190),
                              child: RaisedButton(
                                onPressed: () async {
                                  imageTemp = null;
                                  tempPop = await Navigator.push<dynamic>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => CameraOpen()));
                                  setState(() {
                                    baseImage = tempPop[0];
                                    imageTemp = tempPop[1];
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30))),
                                padding: EdgeInsets.all(.0),
                                child: Ink(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.amber,
                                          Colors.amber[600],
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(30),
                                          bottomLeft: Radius.circular(30))),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: 250.0, minHeight: 50.0),
                                    alignment: Alignment.center,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "Tambah",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: new Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(
                                color: Colors.black12,
                                thickness: 1,
                                height: 36,
                              ))),
                    ],
                  ),
                  Expanded(
                      child: Container(
                    child: new GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            for (int i = 0; i < typeList.length; i++)
                              (listWidget[i]),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 100, vertical: 20),
                              child: RaisedButton(
                                onPressed: () {
                                  setState(() {
                                    saveProfile();
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)),
                                padding: EdgeInsets.all(0.0),
                                child: Ink(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xff02070A),
                                          Color(0xff072E43),
                                          Color(0xff072E43)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: 250.0, minHeight: 50.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "SIMPAN",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
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
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 100);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class TypeText extends StatelessWidget {
  FocusNode myFocusNode = new FocusNode();
  final String label;
  TextEditingController controller;

  TypeText(this.label, this.controller);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.amber, width: 10))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: <Widget>[
                Container(
                  // decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  //     color: Color(0xffededed)),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                        suffixIcon:
                            Icon(Icons.edit, size: 15, color: Colors.black54),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                (BorderRadius.all(Radius.circular(8.0))),
                            borderSide: BorderSide(color: Colors.black12)),
                        contentPadding: EdgeInsets.only(
                            bottom: 10.0, left: 10.0, right: 10.0),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            borderSide: BorderSide(color: Colors.amber)),
                        labelText: label,
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? Colors.grey
                                : Colors.grey)),
                    // ignore: missing_return
                    validator: (String value) {
                      if (value.isEmpty) {
                        return "Nama harus diisi";
                      }
                    },
                    onSaved: (String value) {},
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TypeDate extends StatefulWidget {
  final String label;
  TextEditingController controller;

  TypeDate(this.label, this.controller);

  @override
  _TypeDateState createState() => _TypeDateState();
}

class _TypeDateState extends State<TypeDate> {
  DateTime selectedDate = DateTime.now();

  String lab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 100),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.amber, width: 10))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.label,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      )),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: widget.controller.text != ""
                          ? Text(
                              "${selectedDate.toLocal()}".split(' ')[0],
                              style: TextStyle(color: Colors.black),
                            )
                          : Text("Pilih tanggal"),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _selectDate(context);
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;

        widget.controller.text = DateFormat("yyyy/MM/dd")
            .format(DateTime.parse(selectedDate.toString()));
        print(this.widget.controller.text);
      });
    }
  }
}

class TypeDropdown extends StatefulWidget {
  final String label;
  final List<String> value;
  TextEditingController controller;

  TypeDropdown(this.label, this.value, this.controller);

  @override
  _TypeDropdownState createState() => _TypeDropdownState();
}

class _TypeDropdownState extends State<TypeDropdown> {
  MainPage _main = new MainPage();
  String _valResult;

  List<dynamic> _dataProvince = ['halo', 'ada', 'apa', 'dengan', 'kamu'];
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(left: BorderSide(color: Colors.amber, width: 10))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.label,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber))),
                    isExpanded: true,
                    hint: Text("Pilih ${widget.label}"),
                    value: _valResult,
                    items: widget.value.map((value) {
                      return DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (value) {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      setState(() {
                        widget.controller.text = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class TypeRadio extends StatefulWidget {
  final String label;
  final List<String> valueList;
  TextEditingController controller;

  TypeRadio(this.label, this.valueList, this.controller);
  @override
  _TypeRadioState createState() => _TypeRadioState();
}

class _TypeRadioState extends State<TypeRadio> {
  MainPage _main = new MainPage();

  int _value;
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Card(
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(left: BorderSide(color: Colors.amber, width: 10))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.label,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  for (int i = 0; i < widget.valueList.length; i++)
                    ListTile(
                      title: Text(
                        widget.valueList[i],
                        style: Theme.of(context).textTheme.subtitle1.copyWith(
                            color: i == widget.valueList.length
                                ? Colors.black38
                                : Colors.black),
                      ),
                      leading: Radio(
                        value: i,
                        groupValue: _value,
                        onChanged: i == widget.valueList.length
                            ? null
                            : (int value) {
                                setState(() {
                                  _value = value;
                                  widget.controller.text =
                                      widget.valueList[value];
                                });
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
