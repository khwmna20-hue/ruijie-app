import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruijie Cloud App',
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
  final String appSecret = "0dea886911864f359497a65f94164518";

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
      statusMessage = "Ruijie Cloud Server သို့ ချိတ်ဆက်နေပါသည်...";
    });

    final List<String> baseUrls = [
      "https://cloud-as.ruijienetworks.com",
      "https://cloud.ruijienetworks.com",
      "https://cloud-eu.ruijienetworks.com",
    ];

    String? accessToken;
    String workingDomain = "";

    for (String domain in baseUrls) {
      try {
        final tokenUrl = "$domain/service/api/oauth20/client/access_token";
        final response = await http.post(
          Uri.parse(tokenUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'appid': appId,
            'secret': appSecret,
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

    try {
      // &page_num=1&page_size=100 ထည့်သွင်းထားသော URL
      final deviceUrl = "$workingDomain/service/api/maint/devices?access_token=$accessToken&page_num=1&page_size=100";
      final devResponse = await http.get(Uri.parse(deviceUrl));

      if (devResponse.statusCode == 200) {
        final devData = jsonDecode(devResponse.body);
        setState(() {
          devices = devData['data'] ?? devData['list'] ?? devData['deviceList'] ?? [];
          isLoading = false;
          if (devices.isEmpty) {
            statusMessage = "Device များ မတွေ့ရှိပါ။ (အကောင့်ထဲတွင် Device မရှိသေးပါ)";
          }
        });
      } else {
        setState(() {
          statusMessage = "Device List Error Status: ${devResponse.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Fetch Device Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruijie Device List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDevices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      statusMessage.isEmpty ? "Device များ မတွေ့ရှိပါ" : statusMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      leading: const Icon(Icons.router),
                      title: Text(device['devName'] ?? device['name'] ?? 'Unknown Device'),
                      subtitle: Text("SN: ${device['sn'] ?? 'N/A'} | Status: ${device['status'] ?? 'N/A'}"),
                    );
                  },
                ),
    );
  }
}
