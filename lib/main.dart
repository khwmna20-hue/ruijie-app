
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
  final String appId = "openc1be61fb5dc";
  final String appSecret = "0dea686511064f359497a65f34164518";

  List<dynamic> devices = [];
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final tokenRes = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': appId,
          'appSecret': appSecret,
        }),
      );

      if (tokenRes.statusCode != 200) {
        setState(() {
          errorMessage = "Server တုံ့ပြန်မှု မှားယွင်းနေပါသည် (Status: ${tokenRes.statusCode})။ API Endpoint သို့မဟုတ် Server URL စစ်ဆေးပါ။";
          isLoading = false;
        });
        return;
      }

      final tokenData = jsonDecode(tokenRes.body);
      String token = tokenData['accessToken'] ?? tokenData['data']?['accessToken'] ?? '';

      if (token.isEmpty) {
        setState(() {
          errorMessage = "Token တောင်းယူမှု မအောင်မြင်ပါ (App ID / Key စစ်ပေးပါ)";
          isLoading = false;
        });
        return;
      }

      final devRes = await http.get(
        Uri.parse('$baseUrl/api/v1/device/list'),
        headers: {'AccessToken': token},
      );

      if (devRes.statusCode != 200) {
        setState(() {
          errorMessage = "Device List ရယူ၍ မရပါ (Status: ${devRes.statusCode})";
          isLoading = false;
        });
        return;
      }

      final devData = jsonDecode(devRes.body);

      setState(() {
        devices = devData['list'] ?? devData['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "ချိတ်ဆက်မှု မအောင်မြင်ပါ: $e";
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
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : devices.isEmpty
                  ? const Center(child: Text("Device များ မရှိသေးပါ"))
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final dev = devices[index];
                        return ListTile(
                          leading: const Icon(Icons.router),
                          title: Text(dev['devName'] ?? dev['sn'] ?? 'Unknown Device'),
                          subtitle: Text(dev['model'] ?? dev['ip'] ?? ''),
                        );
                      },
                    ),
    );
  }
}
