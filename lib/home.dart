import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String predictedEmotion = "";
  bool isDetecting = false;
  Interpreter? interpreter;

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/MLmodel/model.tflite');
      print("✅ Model loaded successfully");
    } catch (e) {
      print("❌ Error loading model: $e");
    }
  }

  Future<void> loadCamera() async {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);

    try {
      await cameraController!.initialize();
      cameraController!.startImageStream((image) {
        cameraImage = image;
        runModel();
      });
      print("✅ Camera initialized");
    } catch (e) {
      print("❌ Camera initialization error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initializing camera: $e")),
      );
    }
  }

  void runModel() async {
    if (cameraImage != null && !isDetecting && interpreter != null) {
      isDetecting = true;

      try {
        var input = processCameraImage(cameraImage!);
        var output = List.generate(1, (index) => List.filled(2, 0.0));

        interpreter!.run(input, output);

        setState(() {
          predictedEmotion = output[0][0] > 0.5 ? "Happy" : "Sad";
        });
        print("🎯 Prediction: $predictedEmotion");
      } catch (e) {
        print("❌ Error running model: $e");
      }

      isDetecting = false;
    }
  }

  List<List<List<List<double>>>> processCameraImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final List<List<List<List<double>>>> input = List.generate(
      1,
          (_) => List.generate(
        48,
            (y) => List.generate(
          48,
              (x) => List.generate(1, (_) {
            int pixelX = (x * width) ~/ 48;
            int pixelY = (y * height) ~/ 48;
            int index = pixelY * width + pixelX;
            int yVal = image.planes[0].bytes[index];
            return yVal / 255.0;
          }),
        ),
      ),
    );

    return input;
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((_) => loadCamera());
  }

  @override
  void dispose() {
    cameraController?.dispose();
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Live Emotion Detection'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: cameraController != null &&
                  cameraController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            predictedEmotion,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 50,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
