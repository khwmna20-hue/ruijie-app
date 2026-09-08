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
  final String appId = "openc3be644fb5dc";
  final String appSecret = "0dea686511064f359497a65f34164518";

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
      debugLog = "=== Full Multi-Server Diagnostic ===\n\n";
    });

    // Ruijie Cloud Server Domains
    final List<String> baseUrls = [
      "https://cloud-as.ruijienetworks.com",
      "https://cloud.ruijienetworks.com",
      "https://cloud-eu.ruijienetworks.com",
    ];

    // API Path Variations
    final List<String> authEndpoints = [
      "/service/api/v1/auth/token",
      "/service/api/v1/token",
      "/open/api/v1/auth/token",
      "/api/v1/auth/token",
      "/open/v1/auth/token",
      "/service/api/v2/auth/token",
    ];

    String workingBaseUrl = "";
    String workingAuthPath = "";
    String token = "";

    for (String domain in baseUrls) {
      for (String path in authEndpoints) {
        final url = "$domain$path";
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
              workingBaseUrl = domain;
              workingAuthPath = path;
              debugLog += "SUCCESS: Found -> $domain$path\n";
              break;
            } else {
              debugLog += "200 OK (No Token): $url\n";
            }
          } else {
            debugLog += "FAIL [Status ${res.statusCode}]: $domain$path\n";
          }
        } catch (e) {
          debugLog += "ERR: $domain$path\n";
        }
      }
      if (token.isNotEmpty) break;
    }

    if (token.isEmpty) {
      setState(() {
        debugLog += "\n⚠️ Server အားလုံးနှင့် API Path များ စစ်ဆေးခဲ့ပြီး မှန်ကန်သော Endpoint ရှာမတွေ့ပါ။";
        isLoading = false;
      });
      return;
    }

    // Token ရပါက Device List ခေါ်ယူခြင်း
    final String devPath = workingAuthPath.replaceAll("auth/token", "device/list").replaceAll("token", "device/list");
    try {
      final devRes = await http.get(
        Uri.parse("$workingBaseUrl$devPath"),
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
          debugLog += "\nDevice List Status: ${devRes.statusCode} - ${devRes.body}";
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
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
    );
  }
}
