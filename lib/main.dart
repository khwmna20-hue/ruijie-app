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
      title: 'Ruijie Reyee Dashboard',
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
  String statusMessage = "";

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
      statusMessage = "Ruijie Cloud Server သို့ ချိတ်ဆက်နေပါသည်။...";
    });

    final List<String> baseUrls = [
      "https://cloud-as.ruijienetworks.com",
      "https://cloud.ruijienetworks.com",
      "https://cloud-eu.ruijienetworks.com",
    ];

    String? accessToken;
    String workingDomain = "";

    // 1. Ruijie Official Access Token Endpoint
    for (String domain in baseUrls) {
      try {
        final tokenUrl = "$domain/service/api/oauth20/client/access_token";
        final response = await http.post(
          Uri.parse(tokenUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'appid': appId,
            'secret': appSecret
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['accessToken'] != null && data['accessToken'].toString().isNotEmpty) {
            accessToken = data['accessToken'];
            workingDomain = domain;
            break;
          } else if (data['code'] != null && data['code'] != 0) {
            statusMessage = "Ruijie API Error: ${data['msg']} (Code: ${data['code']})";
          }
        } else {
          statusMessage = "HTTP Error Status: ${response.statusCode}";
        }
      } catch (e) {
        statusMessage = "Connection Error: $e";
      }
    }

    if (accessToken == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // 2. Fetch Devices List
    try {
      final deviceUrl = "$workingDomain/service/api/maint/devices?access_token=$accessToken";
      final devResponse = await http.get(Uri.parse(deviceUrl));

      if (devResponse.statusCode == 200) {
        final devData = jsonDecode(devResponse.body);
        setState(() {
          devices = devData['data'] ?? devData['list'] ?? devData['devices'] ?? [];
          isLoading = false;
          if (devices.isEmpty) {
            statusMessage = "Device များ မတွေ့ရှိပါ။ (အကောင့်ထဲတွင် Device ထည့်ထားခြင်း မရှိပါ)";
          }
        });
      } else {
        setState(() {
          statusMessage = "Device List Fetch Failed [Code: ${devResponse.statusCode}]";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Error: $e";
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(statusMessage),
                ],
              ),
            )
          : devices.isNotEmpty
              ? ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final dev = devices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          dev['online'] == true || dev['status'] == 'online'
                              ? Icons.router
                              : Icons.router_outlined,
                          color: dev['online'] == true || dev['status'] == 'online'
                              ? Colors.green
                              : Colors.grey,
                        ),
                        title: Text(
                          dev['devName'] ?? dev['deviceName'] ?? dev['sn'] ?? 'Unknown Device',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Model: ${dev['model'] ?? 'N/A'}\nSN: ${dev['sn'] ?? 'N/A'} | IP: ${dev['ip'] ?? 'N/A'}",
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchDevices,
                        child: const Text("ပြန်လည် စမ်းသပ်မည်"),
                      )
                    ],
                  ),
                ),
    );
  }
}
