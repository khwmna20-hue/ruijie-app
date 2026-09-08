import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const RuijieApp());
}

class RuijieApp extends StatelessWidget {
  const RuijieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruijie Reyee Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DashBoardScreen(),
    );
  }
}

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final String baseUrl = "https://cloud-as.ruijienetworks.com";
  final String appId = "openc3be644fb5dc";
  final String appSecret = "0dea886911864f359497a65f94164518";

  List<dynamic> devices = [];
  bool isLoading = false;
  String debugLog = "";

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
      debugLog = "=== Ruijie API Auto Diagnostic ===\n\n";
    });

    // Ruijie Cloud ၏ ဖြစ်နိုင်ခြေရှိသော Auth URL လမ်းကြောင်းများ အားလုံး စစ်ဆေးခြင်း
    final List<String> authEndpoints = [
      "/service/api/v1/auth/token",
      "/api/v1/auth/token",
      "/open/v1/auth/token",
      "/api/open/v1/auth/token",
    ];

    String workingAuthPath = "";
    String token = "";

    for (String path in authEndpoints) {
      final url = "$baseUrl$path";
      try {
        final res = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'appId': appId, 'appSecret': appSecret}),
        );

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          token = data['accessToken'] ?? data['data']?['accessToken'] ?? '';
          if (token.isNotEmpty) {
            workingAuthPath = path;
            debugLog += "SUCCESS: Auth Path မာန်ပါသည် -> $path\n";
            break;
          } else {
            debugLog += "FAIL: $path (Token မရပါ - ${res.body})\n";
          }
        } else {
          debugLog += "FAIL: $path [Status Code: ${res.statusCode}]\n";
        }
      } catch (e) {
        debugLog += "ERROR: $path [$e]\n";
      }
    }

    if (token.isEmpty) {
      setState(() {
        debugLog += "\n⚠️ URL လမ်းကြောင်းများ အားလုံး 404 ဖြစ်နေပါသည်။ အထက်ပါ Log ကို ကြည့်၍ စစ်ဆေးနိုင်ပါသည်။";
        isLoading = false;
      });
      return;
    }

    // Token ရပါက Device List လှမ်းတောင်းခြင်း
    final String devPath = workingAuthPath.replaceAll("/auth/token", "/device/list");
    try {
      final devRes = await http.get(
        Uri.parse("$baseUrl$devPath"),
        headers: {'AccessToken': token},
      );

      if (devRes.statusCode == 200) {
        final devData = jsonDecode(devRes.body);
        setState(() {
          devices = devData['list'] ?? devData['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          debugLog += "\nDevice List Error [Status: ${devRes.statusCode}] - ${devRes.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        debugLog += "\nDevice List Exception: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruijie Reyee Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDevices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : devices.isNotEmpty
              ? ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final dev = devices[index];
                    return ListTile(
                      leading: const Icon(Icons.router),
                      title: Text(dev['devName'] ?? dev['sn'] ?? 'Unknown Device'),
                      subtitle: Text(dev['model'] ?? dev['ip'] ?? ''),
                    );
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      debugLog,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: debugLog.contains("SUCCESS") ? Colors.green : Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
    );
  }
}
