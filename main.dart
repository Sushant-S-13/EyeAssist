import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

void main() {
  runApp(const CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSpeech(); // Initialize TTS and STT
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _speech.stop();
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_speechAvailable && !_speech.isListening) {
      _startListening();
    }
  }

  void _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" || status == "notListening") {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) => print("Speech error: $error"),
    );

    if (_speechAvailable) {
      await _tts.speak("Welcome to EyeAssist. Say a command to continue.");
      _tts.setCompletionHandler(() {
        _startListening();
      });
    } else {
      await _tts.speak("Speech recognition not available.");
    }
  }

  void _startListening() async {
    if (!_speechAvailable || _speech.isListening) return;

    // Start listening
    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        partialResults: true,
      ),
      onResult: (result) {
        if (result.finalResult) {
          _handleCommand(result.recognizedWords.toLowerCase());
        }
      },
    );

    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _handleCommand(String command) async {
    _stopListening();

    if (command.contains("currency")) {
      await _tts.speak("Opening currency recognition.");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CurrencyDetectorScreen()),
      );
    } else if (command.contains("read") || command.contains("aloud")) {
      await _tts.speak("Opening read aloud.");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReadAloudScreen()),
      );
    } else if (command.contains("image") || command.contains("chat")) {
      await _tts.speak("Opening image chat.");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ImageChatScreen()),
      );
    } else if (command.contains("walk") || command.contains("along")) {
      await _tts.speak("Opening Walk Along mode.");
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalkAlongScreen()),
      );
    } else {
      await _tts.speak("Sorry, I didn't understand. Try again.");
    }

    // Restart listening when back on this screen
    _startListening();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_speechAvailable) {
          if (_isListening) {
            await _tts.speak("Already listening");
          } else {
            await _tts.speak("Listening");
            _startListening();
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color.fromARGB(255, 53, 52, 52)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "EyeAssist",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildButton(
                title: "Currency Recognition",
                gradientColors: [Colors.green, Colors.white],
                onPressed: () async {
                  _stopListening();
                  await _tts.speak("Starting currency recognition.");
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencyDetectorScreen(),
                    ),
                  );
                  _startListening();
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                title: "Read Aloud",
                gradientColors: [Colors.purple, Colors.white],
                onPressed: () async {
                  _stopListening();
                  await _tts.speak("Starting Read Aloud mode.");
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadAloudScreen(),
                    ),
                  );
                  _startListening();
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                title: "Image Chat",
                gradientColors: [Colors.red, Colors.white],
                onPressed: () async {
                  _stopListening();
                  await _tts.speak("Starting image chat.");
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImageChatScreen(),
                    ),
                  );
                  _startListening();
                },
              ),
              const SizedBox(height: 20),
              _buildButton(
                title: "Walk Along",
                gradientColors: [Colors.blue, Colors.white],
                onPressed: () async {
                  _stopListening();
                  await _tts.speak("Starting Walk Along mode.");
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WalkAlongScreen(),
                    ),
                  );
                  _startListening();
                },
              ),
              const SizedBox(height: 30),
              Text(
                _isListening ? "Listening for commands..." : "Not listening",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //stop
  Widget _buildButton({
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              title,
              style: const TextStyle(fontSize: 22, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ Currency & Read Aloud Screens ------------------

class CurrencyDetectorScreen extends StatefulWidget {
  const CurrencyDetectorScreen({super.key});
  @override
  _CurrencyDetectorScreenState createState() => _CurrencyDetectorScreenState();
}

class _CurrencyDetectorScreenState extends State<CurrencyDetectorScreen> {
  File? _image;
  String _resultText = "Preparing to capture image...";
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _startCaptureSequence();
  }

  void _startCaptureSequence() async {
    await Future.delayed(const Duration(seconds: 3));
    _tts.speak("Place your camera to capture the image.");
    
    await Future.delayed(const Duration(seconds: 2));
    _pickImage();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _resultText = "Image captured. Initiating currency detection...";
      });
      _tts.speak("Image captured. Initiating currency detection.");
      _uploadImage(_image!);
    } else {
      _tts.speak("Image capture failed.");
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var response = await http.post(
        Uri.parse("http://192.168.116.1:5000/detect"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List detections = responseData['detections'];

        String detectedText = detections.isNotEmpty
            ? "Detected: ${detections.map((d) => "${d['class']} (${(d['confidence'] * 100).toStringAsFixed(2)}%)").join(", ")}"
            : "No currency detected.";

        setState(() {
          _resultText = detectedText;
        });

        _tts.speak(detectedText);
      } else {
        _tts.speak("An error occurred.");
      }
    } catch (e) {
      _tts.speak("Failed to process image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildResultScreen(_image, _resultText);
  }
}

class ReadAloudScreen extends StatefulWidget {
  const ReadAloudScreen({super.key});
  @override
  _ReadAloudScreenState createState() => _ReadAloudScreenState();
}

class _ReadAloudScreenState extends State<ReadAloudScreen> {
  File? _image;
  String _detectedText = "Preparing to capture image...";
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  @override
  void initState() {
    super.initState();
    _startCaptureSequence();
  }

  void _startCaptureSequence() async {
    await Future.delayed(const Duration(seconds: 3));
    _tts.speak("Place your camera to capture the image.");
    await Future.delayed(const Duration(seconds: 2));
    _pickImage();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _detectedText = "Extracting text...";
      });
      _extractText(imageFile);
    } else {
      _tts.speak("Image capture failed.");
    }
  }

  Future<void> _extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    String text =
        recognizedText.text.isNotEmpty
            ? recognizedText.text
            : "No readable text found.";
    setState(() {
      _detectedText = text;
    });
    _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildResultScreen(_image, _detectedText);
  }
}

// ------------------ Image Chat Screen ------------------

class ImageChatScreen extends StatefulWidget {
  const ImageChatScreen({super.key});
  @override
  State<ImageChatScreen> createState() => _ImageChatScreenState();
}

class _ImageChatScreenState extends State<ImageChatScreen> {
  File? _image;
  String _question = "";
  String _response = "";
  final FlutterTts _tts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();

  final String apiKey = "YOUR GEMINI API KEY";

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(seconds: 2));
    await _tts.speak("Place your camera to take image");
    await Future.delayed(const Duration(seconds: 2));
    await _pickImage();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _tts.speak("Image captured. Now ask your question.");
      await Future.delayed(const Duration(seconds: 2));
      _listenForQuestion();
    } else {
      await _tts.speak("Image capture failed.");
    }
  }

  Future<void> _listenForQuestion() async {
    bool available = await _speech.initialize();
    if (available) {
      await _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            setState(() {
              _question = result.recognizedWords;
            });
            await _tts.speak("You said: $_question. Generating response...");
            await _generateResponse();
          }
        },
      );
    } else {
      await _tts.speak("Speech recognition not available.");
    }
  }

  Future<void> _generateResponse() async {
    if (_image == null || _question.isEmpty) return;

    final bytes = _image!.readAsBytesSync();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": _question},
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
            },
          ],
        },
      ],
    });

    final response = await http.post(
      Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey",
      ),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    final jsonResp = jsonDecode(response.body);
    final text =
        jsonResp['candidates']?[0]['content']['parts']?[0]['text'] ??
        "No response from model";

    setState(() {
      _response = text;
    });

    await _tts.speak(_response);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildResultScreen(
      _image,
      "You asked: $_question\n\nResponse:\n$_response",
    );
  }
}

// ------------------ Walk Along Mode ------------------
class WalkAlongScreen extends StatefulWidget {
  const WalkAlongScreen({super.key});

  @override
  State<WalkAlongScreen> createState() => _WalkAlongScreenState();
}

class _WalkAlongScreenState extends State<WalkAlongScreen> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  FlutterTts flutterTts = FlutterTts();
  String _obstacleText = "No obstacles detected";

  final String serverUrl = 'http://192.168.116.1:10000/walkalong';

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) return;
    setState(() {});
    startImageStream();
  }

  void startImageStream() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final XFile file = await _cameraController!.takePicture();
        File imageFile = File(file.path);

        var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await http.Response.fromStream(response);
          final obstacles = parseObstacles(responseData.body);
          handleObstacles(obstacles);
        } else {
          print('Server error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending image: $e');
      }

      _isDetecting = false;
    });
  }

  List<Map<String, dynamic>> parseObstacles(String responseBody) {
    final data =
        responseBody.isNotEmpty
            ? Map<String, dynamic>.from(jsonDecode(responseBody))
            : null;
    if (data == null || !data.containsKey('obstacles')) return [];

    final obstacles = data['obstacles'] as List<dynamic>;
    return obstacles.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> handleObstacles(List<Map<String, dynamic>> obstacles) async {
    if (obstacles.isEmpty) {
      setState(() {
        _obstacleText = "No obstacles detected";
      });
      return;
    }

    String speakText = "";
    for (var obs in obstacles) {
      speakText += "${obs['label']} at ${obs['distance']} meters. ";
    }

    setState(() {
      _obstacleText = speakText;
    });

    await flutterTts.speak(speakText);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "WalkAlong Mode",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40), // Adds space above the camera preview
          AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _obstacleText,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
// ------------------ Shared Result UI Builder ------------------

Widget _buildResultScreen(File? image, String text) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color.fromARGB(255, 53, 52, 52)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image != null
                  ? Image.file(
                    image,
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  )
                  : const Icon(
                    Icons.camera_alt,
                    size: 100,
                    color: Colors.white,
                  ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
