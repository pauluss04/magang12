import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hara_anargya/main_page.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  PermissionStatus _permissionStatus;
  Map<String, String> paket = {};

  List<String> typeBioList = [];
  List<String> attBioList = [];
  List<String> labBioList = [];
  List<String> tipeAtribut = [];
  List<String> dropdownSatu = [];
  List<String> dropdownDua = [];
  List<String> dropdownTiga = [];
  List<String> radioSatu = [];
  List<String> radioDua = [];
  List<String> radioTiga = [];
  List<String> radioEmpat = [];
  int indexDropdown = 0;
  int indexRadio = 0;
  int idAlatTes;
  int cameraTime;
  int tesTime;
  String baseImage = '';

  final String sUrl = "https://dashboard.anargya.id/api/login";

  bool visible = false;
  bool _keyboardVisible = false;

  bool _obscuretextlogin = true;
  bool _obscuretextsignup = true;

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController namaEventController = new TextEditingController();

  int _pageState = 0;

  var _backgroundColor = Colors.white;
  var _backgroundColortwo = Colors.white;
  var _headingColor = Color(0xFFB40284A);

  double _headingTop = 100;

  double _loginWidth = 0;
  double _loginHeight = 0;
  double _registerHeight = 0;
  double _loginOpacity = 1;

  double _loginYOffset = 0;
  double _loginXoffset = 0;
  double _registerYoffset = 0;

  double windowWidth = 0;
  double windowHeight = 0;

  Map<String, String> data = {};

  @override
  void initState() {
    super.initState();
    disableCapture();

    KeyboardVisibilityNotification().addNewListener(onChange: (bool visible) {
      setState(() {
        _keyboardVisible = visible;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback(onLayoutDone);
  }

  void onLayoutDone(Duration timeStamp) async {
    _permissionStatus = await Permission.camera.status;
    setState(() {});
  }

  Future<void> disableCapture() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  _cekLogin() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      visible = true;
    });

    final prefs = await SharedPreferences.getInstance();

    var res = await http.post(sUrl, body: {
      "name": usernameController.text,
      "password": passwordController.text,
      "event_id": prefs.getInt('event_id').toString()
    });
    var response = json.decode(res.body);

    if (res.statusCode == 200) {
      String token = response['token'];
      int bioLength = response['fieldProfile']['general'].length;
      idAlatTes = response['test'][0]['id'];
      cameraTime = response['test'][0]['camera_timer'];
      var time = response['test'][0]['waktu'] * 60;
      tesTime = time.toInt();

      for (int i = 0; i < bioLength; i++) {
        typeBioList.add(response['fieldProfile']['general'][i]['type']);
        labBioList.add(response['fieldProfile']['general'][i]['label']);
        attBioList.add(response['fieldProfile']['general'][i]['attribute']);
        if (response['fieldProfile']['general'][i]['type'] == "dropdown") {
          if (indexDropdown == 0) {
            var value = response['fieldProfile']['general'][i]['value'];
            value.forEach((k, v) {
              dropdownSatu
                  .add(response['fieldProfile']['general'][i]['value'][k]);
            });
          } else if (indexDropdown == 1) {
            var value = response['fieldProfile']['general'][i]['value'];
            value.forEach((k, v) {
              dropdownDua
                  .add(response['fieldProfile']['general'][i]['value'][k]);
            });
          } else if (indexDropdown == 2) {
            var value = response['fieldProfile']['general'][i]['value'];
            value.forEach((k, v) {
              dropdownTiga
                  .add(response['fieldProfile']['general'][i]['value'][k]);
            });
          }
          indexDropdown++;
        }
        if (response['fieldProfile']['general'][i]['type'] == "radio") {
          if (indexRadio == 0) {
            var value = response['fieldProfile']['general'][i]['value'];
            value.forEach((k, v) {
              radioSatu.add(response['fieldProfile']['general'][i]['value'][k]);
            });
          } else if (indexRadio == 1) {
            var value = response['fieldProfile']['general'][i]['value'];
            value.forEach((k, v) {
              radioDua.add(response['fieldProfile']['general'][i]['value'][k]);
            });
          } else if (indexRadio == 2) {
            var value = response['fieldProfile']['general'][i]['value'];
            value.forEach((k, v) {
              radioTiga.add(response['fieldProfile']['general'][i]['value'][k]);
            });
          } else if (indexRadio == 3) {
            var value = response['fieldProfile']['general'][i]['value'];
            value.forEach((k, v) {
              radioEmpat
                  .add(response['fieldProfile']['general'][i]['value'][k]);
            });
          }
          indexRadio++;
        }
      }

      prefs.setInt('cameraTIme', cameraTime);
      prefs.setInt('idAlatTes', idAlatTes);
      prefs.setInt('tesTime', tesTime);
      prefs.setStringList('typeBioList', typeBioList);
      prefs.setStringList('labBioList', labBioList);
      prefs.setStringList('attBioList', attBioList);
      prefs.setStringList('dropSatu', dropdownSatu);
      prefs.setStringList('dropDua', dropdownDua);
      prefs.setStringList('dropTiga', dropdownTiga);
      prefs.setStringList('radioSatu', radioSatu);
      prefs.setStringList('radioDua', radioDua);
      prefs.setStringList('radioTiga', radioTiga);
      prefs.setStringList('radioEmpat', radioEmpat);
      prefs.setString('base64', baseImage);
      prefs.setString('username', usernameController.text);
      prefs.setString('token', token);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return MainPage();
      }));
    } else if (usernameController.text == "" || passwordController.text == "") {
      setState(() {
        visible = false;
      });
      _showAlertDialog(context, "Username atau password tidak boleh kosong");
    } else {
      setState(() {
        visible = false;
      });

      _showAlertDialog(context, response['error']);
    }
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
    windowHeight = MediaQuery.of(context).size.height;
    windowWidth = MediaQuery.of(context).size.width;

    _loginHeight = windowHeight - 270;
    _registerHeight = windowHeight - 270;
    switch (_pageState) {
      case 0:
        _backgroundColor = Colors.white;
        _backgroundColortwo = Colors.white;
        _headingColor = Color(0xff072E43);
        FocusScope.of(context).requestFocus(FocusNode());
        _headingTop = 100;

        _loginOpacity = 1;
        _loginWidth = windowWidth;

        _loginYOffset = windowHeight;
        _loginXoffset = 0;
        _registerYoffset = windowHeight;
        break;
      case 1:
        _backgroundColor = Color(0xff02070A);
        _backgroundColortwo = Color(0xff072E43);
        _headingColor = Colors.white;

        _headingTop = 90;

        _loginOpacity = 1;
        _loginWidth = windowWidth;

        _loginYOffset = _keyboardVisible ? 150 : 230;
        _loginHeight = _keyboardVisible ? windowHeight : windowHeight - 230;
        _loginXoffset = 0;
        _registerYoffset = windowHeight;
        break;
      case 2:
        _backgroundColor = Color(0xff02070A);
        _headingColor = Colors.white;

        _headingTop = 80;

        _loginOpacity = 0.7;
        _loginWidth = windowWidth - 40;

        _loginYOffset = _keyboardVisible ? 150 : 200;
        _loginHeight = _keyboardVisible ? windowHeight : windowHeight - 200;

        _loginXoffset = 20;
        _registerYoffset = _keyboardVisible ? 180 : 230;
        _registerHeight = _keyboardVisible ? windowHeight : windowHeight - 230;
        break;
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Nunito'),
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              AnimatedContainer(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: Duration(milliseconds: 1000),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [_backgroundColor, _backgroundColortwo])),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _pageState = 0;
                        });
                      },
                      child: Container(
                          color: Color.fromRGBO(255, 255, 255, 0),
                          child: Column(
                            children: <Widget>[
                              AnimatedContainer(
                                curve: Curves.fastLinearToSlowEaseIn,
                                duration: Duration(milliseconds: 1000),
                                margin: EdgeInsets.only(top: _headingTop),
                                child: Text(
                                  "Hara Anargya",
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: _headingColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                margin: EdgeInsets.only(
                                    top: 20, left: 20, right: 20),
                                child: Text(
                                  "The smartest way for psychological assessment and we don't give you services, we give you solutions",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _headingColor,
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: MediaQuery.of(context).size.width * 0.5,
                          width: MediaQuery.of(context).size.width * 0.5,
                        ),
                      ),
                    ),
                    Container(
                        child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_pageState != 0) {
                            _pageState = 0;
                          } else {
                            _pageState = 1;
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(32),
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Color(0xFFDDB258),
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                          child: Text(
                            "Get Started",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
              ),

              //LOGIN PERTAMA == LOGIN PERTAMA == LOGIN PERTAMA == LOGIN PERTAMA == LOGIN PERTAMA == LOGIN PERTAMA == LOGIN PERTAMA ==
              AnimatedContainer(
                padding: EdgeInsets.all(32),
                width: _loginWidth,
                height: _loginHeight,
                curve: Curves.fastLinearToSlowEaseIn,
                duration: Duration(milliseconds: 1000),
                transform:
                    Matrix4.translationValues(_loginXoffset, _loginYOffset, 1),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_loginOpacity),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: <Widget>[
                              Text("Login To Continue",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: usernameController,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixIcon: Icon(Icons.email),
                                          suffixIcon: IconButton(
                                            onPressed: () =>
                                                usernameController.clear(),
                                            icon: Icon(Icons.clear),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          hintText: "Enter Email..."),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: _obscuretextlogin,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscuretextlogin
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            onPressed: () {
                                              setState(() {});
                                              _obscuretextlogin =
                                                  !_obscuretextlogin;
                                            },
                                          ),
                                          prefixIcon:
                                              Icon(Icons.vpn_key_rounded),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          hintText: "Enter Password..."),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        //InputWithIconTwo(),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _pageState = 2;
                                    });
                                  },
                                  child: Text("Forgot Password?",
                                      style: GoogleFonts.raleway(
                                          fontSize: 15, color: Colors.black38)),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        GestureDetector(
                            onTap: _cekLogin,

                            // Navigator.pushReplacement(context,
                            //     MaterialPageRoute(builder: (context) {
                            //   return MainPage();
                            // }));

                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFDDB258),
                                  borderRadius: BorderRadius.circular(50)),
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  ("Login"),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            )),
                        SizedBox(height: 10),
                        //               Container(
                        //   decoration: BoxDecoration(
                        //       border: Border.all(color: Color(0xFFB40284A), width: 2),
                        //       borderRadius: BorderRadius.circular(50)),
                        //   padding: EdgeInsets.all(15),
                        //   child: Center(
                        //     child: Text(
                        //       widget.btnText,
                        //       style: TextStyle(color: Color(0xFFB40284A), fontSize: 16),
                        //     ),
                        //   ),
                        // );
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _pageState = 2;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFDDB258), width: 2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  ("Create New Account"),
                                  style: TextStyle(
                                    color: Color(0xff072E43),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ),
                    Expanded(
                      child: Container(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            "App Version 17.0.0",
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              //SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP SIGNUP
              AnimatedContainer(
                height: _registerHeight,
                padding: EdgeInsets.all(32),
                curve: Curves.fastLinearToSlowEaseIn,
                duration: Duration(milliseconds: 1000),
                transform: Matrix4.translationValues(0, _registerYoffset, 1),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Create a New Account",
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: usernameController,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          prefixIcon: Icon(Icons.email),
                                          suffixIcon: IconButton(
                                            onPressed: () =>
                                                usernameController.clear(),
                                            icon: Icon(Icons.clear),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          hintText: "Enter Email..."),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: passwordController,
                                      obscureText: _obscuretextsignup,
                                      decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          suffixIcon: IconButton(
                                            icon: Icon(_obscuretextsignup
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            onPressed: () {
                                              setState(() {});
                                              _obscuretextsignup =
                                                  !_obscuretextsignup;
                                            },
                                          ),
                                          prefixIcon:
                                              Icon(Icons.vpn_key_rounded),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          hintText: "Enter Password..."),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        GestureDetector(
                            onTap: _cekLogin,

                            // Navigator.pushReplacement(context,
                            //     MaterialPageRoute(builder: (context) {
                            //   return MainPage();
                            // }));

                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(0xFFDDB258),
                                  borderRadius: BorderRadius.circular(50)),
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  ("Create Account"),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                _pageState = 1;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xFFDDB258), width: 2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: Text(
                                  ("Back To Login"),
                                  style: TextStyle(
                                    color: Color(0xff072E43),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ),
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
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
                  title: new Text('Perhatian'),
                  content:
                      new Text('Apa kamu yakin ingin keluar dari aplikasi?'),
                  actions: <Widget>[
                    new FlatButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Tidak'),
                    ),
                    new FlatButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Iya'),
                    )
                  ],
                )) ??
        false;
  }
}
