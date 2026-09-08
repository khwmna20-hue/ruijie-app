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
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String baseUrl = "https://cloud-as.ruijienetworks.com";
  final String appId = "openc3be644fb5dc";
  final String appSecret = "0dea886911864f359497a65f94164518";

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

      final tokenData = jsonDecode(tokenRes.body);
      String token = tokenData['accessToken'] ?? tokenData['data']?['accessToken'] ?? '';

      if (token.isEmpty) {
        setState(() {
          errorMessage = "Token တောင်းယူ၍ မရပါ။ App ID / Key စစ်ဆေးပါ။";
          isLoading = false;
        });
        return;
      }

      final devRes = await http.get(
        Uri.parse('$baseUrl/api/v1/device/list'),
        headers: {'AccessToken': token},
      );

      final devData = jsonDecode(devRes.body);
      setState(() {
        devices = devData['data'] ?? [];
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
        title: const Text('Ruijie Reyee Dashboard'),
        centerTitle: true,
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
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : devices.isEmpty
                  ? const Center(child: Text('Device များ ရှာမတွေ့ပါ။'))
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final dev = devices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              Icons.router,
                              color: dev['status'] == 'online' ? Colors.green : Colors.grey,
                            ),
                            title: Text(dev['sn'] ?? 'SN မရှိပါ'),
                            subtitle: Text('Model: ${dev['model'] ?? 'N/A'} | Status: ${dev['status'] ?? 'N/A'}'),
                          ),
                        );
                      },
                    ),
    );
  }
}
