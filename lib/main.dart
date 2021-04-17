import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:find_the_vehicle/helper.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    ));

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String string = "Find Vehicle Owner Details";
  File _userImageFile;
  File _captchaImageFile;
  String _captchaValue = "";
  var result = "";

  ImagePicker picker = ImagePicker();

  void _pickImage(ImageSource imageSource) async {
    final pickedImageFile = await picker.getImage(
      source: imageSource,
    );
    setState(() {
      _userImageFile = File(pickedImageFile.path);
    });
  }

  //recognise_Text
  recogniseText() async {
    await Firebase.initializeApp();
    FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(_userImageFile);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(myImage);
    result = "";
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        result = result + ' ' + line.text;
        // setState(() {
        //   result = result + ' ' + line.text;
        // });
      }
    }
    // String simpleText = result.replaceAll(new RegExp(r"\s+"), "");
    // int indexNum = simpleText.indexOf(new RegExp(r'AP[0-9]+[a-zA-Z]'));
    // print(simpleText);
    // print(indexNum);
    // var mySearch = simpleText.substring(indexNum, indexNum + 10);
    // print(mySearch);
    var mySearch = 'AP31BJ2394';
    result = '"' + mySearch + '"';
    List responseData = await getVehicleInfo(result);
    String vehicleDetails = responseData[0];
    String captchaPath = responseData[1];
    setState(() {
      _captchaImageFile = File(captchaPath);
    });
    setState(() {
      result = vehicleDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(string),
          backgroundColor: Colors.blue[300],
        ),
        body: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox( height: 10 ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.orangeAccent.withOpacity(0.3),
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: SizedBox.expand(
                        child: TextButton(
                          child: Text("Scan Image"),
                          onPressed: () {
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox( height: 10 ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: _userImageFile != null
                      ? Container(
                          color: Colors.orangeAccent.withOpacity(0.3),
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          child: _captchaImageFile != null
                              ? Image(
                                  image: FileImage(_captchaImageFile),
                                )
                              : SizedBox.expand(
                                  child: Center(
                                    child: Text("Trying to get data automatically"),
                                  ),
                                ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                ),
                SizedBox( height: 10 ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: _captchaImageFile != null
                      ? TextField(
                          onChanged: (value) => _captchaValue = value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter above captcha here',
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                ),
                SizedBox( height: 10 ),
                TextButton.icon(
                  onPressed: () {
                    recogniseText();
                  },
                  icon: Icon(Icons.image_search),
                  label: Text(
                    'Get Data',
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0), child: Text(result)),
              ],
            ),
          ),
        ));
  }
}
