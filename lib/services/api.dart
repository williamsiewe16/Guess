import 'dart:io';

import 'package:dio/dio.dart';
import "package:permission_handler/permission_handler.dart";
import "package:async/async.dart";

final String appDir = "/storage/emulated/0/Guess";
final apiURL = /*"https://tv-show-subtitles-api.herokuapp.com";*/ "http://192.168.1.1:5000";

Dio dio = new Dio();

Future<dynamic> predict(path) async {
  try{
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(path)
    });
    var res = await dio.post("$apiURL/predict", data: formData);
    var data = res.data;
    File(path).deleteSync();
    return data["marque"];
  }catch(e){
    print(e);
  }
}

Future<dynamic> getDescription(prediction) async {
  try{
    final response = await dio.get("$apiURL/api/show/image");
    Map<String,dynamic> data = response.data;
    return data;
  }catch(e){
    print(e);
  }
}

Future<bool> checkPermission(Permission permission) async{
  PermissionStatus status = await permission.status;
  if(status == PermissionStatus.granted){
    return true;
  }else{
    status = await Permission.storage.request();
    if(status == PermissionStatus.granted){
      return true;
    }else{
      return false;
    }
  }
}