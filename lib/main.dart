// import 'package:firebase_core/firebase_core.dart'; // Commented out: Firebase Core
// import 'package:firebase_database/firebase_database.dart'; // Commented out: Firebase Realtime Database
import 'package:flutter/material.dart';
// import 'package:camera/camera.dart'; // Commented out: Camera plugin
import 'dart:async';
import 'dart:math';
// import 'package:google_maps_flutter/google_maps_flutter.dart'; // Commented out: Google Maps
// import 'package:sqflite/sqflite.dart'; // Commented out: SQLite database
// import 'package:path/path.dart' as path; // Commented out: Path manipulation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Commented out: Firebase initialization
  // final cameras = await availableCameras(); // Commented out: Camera initialization
  runApp(MyApp(/*cameras: cameras*/)); // Removed cameras parameter
}

class MyApp extends StatelessWidget {
  // final List<CameraDescription> cameras; // Commented out: Camera dependency
  const MyApp({/*required this.cameras,*/ Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF00ACC1),
          secondary: Color(0xFF00B8FF),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      home: RobotControlPanel(/*cameras: cameras*/), // Removed cameras parameter
    );
  }
}

class RobotControlPanel extends StatefulWidget {
  // final List<CameraDescription> cameras; // Commented out: Camera dependency
  const RobotControlPanel({/*required this.cameras,*/ Key? key}) : super(key: key);

  @override
  _RobotControlPanelState createState() => _RobotControlPanelState();
}

class _RobotControlPanelState extends State<RobotControlPanel> {
  late Timer _sensorUpdateTimer;
  // late GoogleMapController _mapController; // Commented out: Google Maps controller
  // CameraController? _cameraController; // Commented out: Camera controller
  bool _isCameraInitialized = false;
  bool _isLedOn = false;
  bool _isConnecting = false;
  String _wifiStatus = "Disconnected";
  String _ssid = "";
  final Map<String, String> _sensorData = {
    "Humidity": "Loading...",
    "Pressure": "Loading...",
    "Temperature": "Loading...",
    "Metal": "Scanning..."
  };

  // final DatabaseHelper _dbHelper = DatabaseHelper(); // Commented out: Database helper

  @override
  void initState() {
    super.initState();
    _startSensorUpdates();
    // _initializeCamera(); // Commented out: Camera initialization
  }

  @override
  void dispose() {
    _sensorUpdateTimer.cancel();
    // _cameraController?.dispose(); // Commented out: Camera disposal
    super.dispose();
  }

  void _startSensorUpdates() {
    _sensorUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      setState(() {
        _sensorData["Humidity"] = "${_randomValue(30, 80)}%";
        _sensorData["Pressure"] = "${_randomValue(900, 1100)} hPa";
        _sensorData["Temperature"] = "${_randomValue(15, 35)}°C";
        _sensorData["Metal"] = _randomBool() ? "Metal Detected!" : "No Metal Found";
      });

      // await _dbHelper.insertSensorData(_sensorData); // Commented out: Database insertion
      // final databaseReference = FirebaseDatabase.instance.ref(); // Commented out: Firebase Realtime Database
      // databaseReference.child('sensor_data').push().set(_sensorData); // Commented out: Firebase Realtime Database
    });
  }

  // Future<void> _initializeCamera() async { // Commented out: Camera initialization
  //   try {
  //     _cameraController = CameraController(widget.cameras[0], ResolutionPreset.medium);
  //     await _cameraController!.initialize();
  //     if (!mounted) return;
  //     setState(() => _isCameraInitialized = true);
  //   } catch (e) {
  //     debugPrint("Failed to initialize camera: $e");
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to initialize camera')),
  //       );
  //     }
  //   }
  // }

  double _randomValue(double min, double max) => (min + (max - min) * Random().nextDouble()).roundToDouble();
  bool _randomBool() => Random().nextBool();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Robot Control Panel", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 10,
        backgroundColor: Color(0xFF1E1E1E),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // _buildLiveCameraView(), // Commented out: Camera preview
          _buildSensorSection(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton(Icons.arrow_drop_up, "UP"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton(Icons.arrow_left, "LEFT"),
                  GestureDetector(
                    onTap: () => print("Microphone button tapped"),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            spreadRadius: 4,
                            blurRadius: 7,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mic,
                        color: Colors.purple,
                        size: 40,
                      ),
                    ),
                  ),
                  buildButton(Icons.arrow_right, "RIGHT"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButton(Icons.arrow_drop_down, "DOWN"),
                ],
              ),
            ],
          ),
          _buildWifiSection(),
          // _buildMapView(), // Commented out: Google Maps
          _buildLedControl(),
        ],
      ),
    );
  }

  Widget _buildWifiSection() {
    return _buildCard(
      child: Column(
        children: [
          TextField(
            onChanged: (value) => _ssid = value,
            decoration: InputDecoration(
              labelText: "Wi-Fi SSID",
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFA3))),
              suffixIcon: Icon(Icons.wifi, color: Colors.white70),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _isConnecting ? CircularProgressIndicator(color: Color(0xFF00FFA3)) : _buildButton("Connect", Color(0xFF00FFA3), _connectToWiFi),
              _buildButton("Disconnect", Color(0xFFFF3B30), _disconnectFromWiFi),
            ],
          ),
          SizedBox(height: 10),
          Text(_wifiStatus, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _wifiStatus.contains("Connected") ? Color(0xFF00FFA3) : Color(0xFFFF3B30))),
        ],
      ),
    );
  }

  Widget _buildSensorSection() {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _sensorData.entries.map((e) => _buildSensorIcon(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _buildSensorIcon(String label, String value) {
    return Column(
      children: [
        Icon(Icons.circle, size: 40, color: Color(0xFF00B8FF)),
        SizedBox(height: 5),
        Text("$label\n$value", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  // Widget _buildLiveCameraView() { // Commented out: Camera preview
  //   return _buildCard(
  //     child: Container(
  //       height: 200,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(color: Color(0xFF00FFA3), width: 2),
  //       ),
  //       child: _isCameraInitialized ? CameraPreview(_cameraController!) : Center(child: CircularProgressIndicator(color: Color(0xFF00FFA3))),
  //     ),
  //   );
  // }

  // Widget _buildMapView() { // Commented out: Google Maps
  //   return _buildCard(
  //     child: SizedBox(
  //       height: 200,
  //       child: Center(child: Text("Google Maps Disabled", style: TextStyle(color: Colors.white))),
  //     ),
  //   );
  // }

  Widget _buildLedControl() {
    return _buildCard(
      child: Column(
        children: [
          _buildButton(_isLedOn ? "Turn OFF LED" : "Turn ON LED", _isLedOn ? Color(0xFF00FFA3) : Color(0xFFFF3B30), () => setState(() => _isLedOn = !_isLedOn)),
          SizedBox(height: 10),
          Text(_isLedOn ? "LED is ON" : "LED is OFF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isLedOn ? Color(0xFF00FFA3) : Color(0xFFFF3B30))),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) => Card(
    elevation: 5,
    color: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(padding: EdgeInsets.all(16), child: child),
  );

  Widget _buildButton(String text, Color color, VoidCallback onPressed) => ElevatedButton(
    onPressed: onPressed,
    child: Text(text, style: TextStyle(color: Colors.black)),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  void _connectToWiFi() async {
    if (_ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid SSID')),
      );
      return;
    }
    setState(() => _isConnecting = true);
    try {
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _wifiStatus = "Connected to $_ssid";
        _isConnecting = false;
      });
    } catch (e) {
      setState(() {
        _wifiStatus = "Failed to connect";
        _isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to Wi-Fi')),
      );
    }
  }

  void _disconnectFromWiFi() {
    setState(() {
      _wifiStatus = "Disconnected";
      _ssid = "";
    });
  }

  Widget buildButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => print("$label button tapped"),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 40,
          ),
        ),
      ),
    );
  }
}

// class DatabaseHelper { // Commented out: Database helper
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;

//   factory DatabaseHelper() {
//     return _instance;
//   }

//   DatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String dbPath = path.join(await getDatabasesPath(), 'robot.db');
//     return await openDatabase(
//       dbPath,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE sensor_data(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         humidity TEXT,
//         pressure TEXT,
//         temperature TEXT,
//         metal TEXT,
//         timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
//       )
//     ''');
//   }

//   Future<void> insertSensorData(Map<String, String> data) async {
//     final db = await database;
//     await db.insert(
//       'sensor_data',
//       {
//         'humidity': data['Humidity'],
//         'pressure': data['Pressure'],
//         'temperature': data['Temperature'],
//         'metal': data['Metal'],
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<Map<String, dynamic>>> getSensorData() async {
//     final db = await database;
//     return await db.query('sensor_data');
//   }
// }