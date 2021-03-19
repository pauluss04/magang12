import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hara_anargya/main_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraOpen extends StatefulWidget {
  @override
  _CameraOpenState createState() => _CameraOpenState();
}

class _CameraOpenState extends State<CameraOpen> {
  CameraController controller;
  String base64;
  Uint8List imageTemp;
  File imageFile;
  List<dynamic> tempPop = [];
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.medium);
    await controller.initialize();
  }

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _saveBase() async {
    File result = await takePicture();
    List<int> imageBytes = result.readAsBytesSync();
    String _img64 = base64Encode(imageBytes);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('base64', _img64);
    imageTemp = Base64Decoder().convert(_img64);
    tempPop.add(_img64);
    tempPop.add(imageTemp);
    print(tempPop.length);
    print("SaveBaseRunning");
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<File> takePicture() async {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/Profile_Camera';
    await new Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${DateTime.now()}.jpg';

    try {
      await controller.takePicture(filePath);
    } catch (e) {
      print("Gajadiupload");
      return null;
    }
    return File(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: initializeCamera(),
        builder: (_, snapshot) =>
            (snapshot.connectionState == ConnectionState.done)
                ? Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.width /
                                controller.value.aspectRatio,
                            child: CameraPreview(controller),
                          ),
                          Container(
                            width: 70,
                            height: 70,
                            margin: EdgeInsets.only(top: 50),
                            child: RaisedButton(
                              onPressed: () async {
                                if (!controller.value.isTakingPicture) {
                                  await _saveBase();
                                  Navigator.pop(context, tempPop);
                                }
                              },
                              shape: CircleBorder(),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width /
                              controller.value.aspectRatio,
                          child: Image.asset(
                            'assets/images/cameraguide.png',
                            fit: BoxFit.cover,
                          )),
                    ],
                  )
                : Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    ),
                  ),
      ),
    );
  }
}
