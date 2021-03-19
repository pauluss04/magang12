import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailImage extends StatefulWidget {
  @override
  _DetailImageState createState() => _DetailImageState();
}

class _DetailImageState extends State<DetailImage> {
  File imageFile;
  String base64;
  Image imageBase;
  Image defaultImage;
  void initState() {
    super.initState();
    _baseConvert();
  }

  _baseConvert() async {
    print("detailimage");
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      base64 = prefs.getString('base64');

      final _byteImage = Base64Decoder().convert(base64);
      imageBase = Image.memory(_byteImage);
      defaultImage = Image.asset('assets/images/ProfilePict.png');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Hero(
          tag: 'pp',
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: base64 != '' ? imageBase : defaultImage),
        ),
      ),
    );
  }
}
