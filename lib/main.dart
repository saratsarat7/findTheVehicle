import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

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
        setState(() {
          result = result + ' ' + line.text + '\n';
        });
      }
    }
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
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.orangeAccent.withOpacity(0.3),
                      width: MediaQuery.of(context).size.width,
                      height: 400,
                      child: _userImageFile != null
                          ? GestureDetector(
                              onTap: () {
                                _pickImage(ImageSource.camera);
                              },
                              child: Image(
                                image: FileImage(_userImageFile),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                _pickImage(ImageSource.camera);
                              },
                              child: Center(
                                child: Text("Number Plate"),
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextButton.icon(
                  onPressed: () {
                    recogniseText();
                  },
                  icon: Icon(Icons.image_search),
                  label: Text(
                    'Get Details',
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(10.0), child: Text(result)),
              ],
            ),
          ),
        ));
  }
}
