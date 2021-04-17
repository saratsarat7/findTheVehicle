import 'dart:convert' as convert;
import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:http/http.dart' as http;

var jsonResp = "";

Future<String> getVehicleInfo(String vehicleNumber) async {
  var passed = false;
  String captchaPath = "";
  String captchaId = "";
  int counter = 1;
  do {
    List values = await getCaptchaDetails();
    captchaPath = values[0];
    captchaId = values[1];
    if (captchaPath != '') {
      String solvedCaptcha = await translateCaptcha(captchaPath);
      solvedCaptcha = '"' + solvedCaptcha + '"';
      passed = await queryWithCaptcha(vehicleNumber, captchaId, solvedCaptcha, counter);
      counter++;
    }
  } while (passed == false && counter <= 10);
  return jsonResp;
}

Future<List> getCaptchaDetails () async {
  var url = Uri.https('rtaappsc.epragathi.org:1201', '/reg/citizenServices/generateVehicleSearchCaptcha');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    var captchaId = '"' + jsonResponse['result']['capchaId'] + '"';
    var captchaEncodedImg = jsonResponse['result']['capchaEncodedImg'];
    String imagePath = await decodeImage(captchaEncodedImg);
    return[imagePath, captchaId];
  } else {
    return["", ""];
  }
}

Future<String> decodeImage (String encodedImageString) async {
  final decodedBytes = convert.base64Decode(encodedImageString);

  String captchaPath = '/storage/emulated/0/Android/data/com.deluded.find_the_vehicle/files/captchaImage.png';
  var file = File(captchaPath);
  // file.delete();
  file.writeAsBytesSync(decodedBytes);

  return captchaPath;
}

Future<String> translateCaptcha (captchaLocation) async {
  File captchaFile = File(captchaLocation);
  FirebaseVisionImage myImage = FirebaseVisionImage.fromFile(captchaFile);
  TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
  VisionText readText = await recognizeText.processImage(myImage);
  var result = "";
  for (TextBlock block in readText.blocks) {
    for (TextLine line in block.lines) {
        result = result + ' ' + line.text;
    }
  }
  return result.replaceAll(new RegExp(r"\s+"), "");
}

Future<bool> queryWithCaptcha (prNo, captchaId, captchaValue, counter) async {
  String userReq = '{"prNo":$prNo,"captchaId":$captchaId,"captchaValue":$captchaValue}';
  print(userReq);
  var dataUrl = Uri.https('rtaappsc.epragathi.org:1201', '/reg/citizenServices/applicationSearchForCitizenRequired');
  var header = {"Content-Type": "application/json;charset=utf-8"};
  var response = await http.post(dataUrl, body: userReq, headers: header);

  var statusCode = response.statusCode;
  if (statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    print(jsonResponse);
    if (jsonResponse["status"] == true) {
      jsonResp = jsonResponse["result"].toString();
      return true;
    } else {
      print('Failed $counter times !! Retrying....');
      return false;
    }
  } else {
    print('Failed !! Response Code : $statusCode');
    jsonResp = 'Failed !! Response Code : $statusCode';
    return true;
  }
}