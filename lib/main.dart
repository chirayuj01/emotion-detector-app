import 'package:camera/camera.dart';
import 'package:ed_proj/home.dart';
import 'package:flutter/material.dart';

List<CameraDescription>? cameras;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras=await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

