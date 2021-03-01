import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import "package:async/async.dart";
import 'dart:io';
import "package:guess_mobile_app/services/api.dart";
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initAppDir();

  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}


void initAppDir() async {
  Directory dir = Directory("$appDir/images");
  if(await checkPermission((Permission.storage))){
    if(!await dir.exists()){
      dir.create(recursive: true);
      print('created');
    }
  }
}

class MyApp extends StatelessWidget {
  MyApp({this.camera});
  final camera;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(

        child:  MyHomePage(camera: camera),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool active = true;
  String prediction = "Flutter";

  @override
  void initState(){
    super.initState();
    if(Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.ultraHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            var link = "https://www.google.com/search?q=$prediction&sxsrf=ALeKk00Zz3dSVBPzWOAqfw0NMLCXaNiT7w:1614389058733&source=lnms&tbm=isch&sa=X&ved=2ahUKEwiszP_y84jvAhUxyoUKHeWZBDUQ_AUoAnoECAwQBA&biw=1848&bih=981";
            print(active);
            print('**************************************************************');
            print('**************************************************************');
            print('**************************************************************');
            var widget = !active ?
                WebView(initialUrl: link, javascriptMode: JavascriptMode.disabled)
             : CameraPreview(_controller);
            return Center(
              child: widget
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Transform.scale(
        scale: 1.1,
        child: FloatingActionButton(
          child: Icon(Icons.camera_alt),
          onPressed: () async {
            try{
              final image = await takePicture();

            }catch(e){
              print('impossible to take a pic');
              print(e);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if(active){
      await _initializeControllerFuture;
      String path = "$appDir/images/${DateTime.now()}.png";
      await _controller.takePicture(path);
      var marque = await predict(path);
      setState(() {
        active = !active;
        prediction = marque;
      });
    }else{
      setState(() {
        active = !active;
      });
    }
  }
}
