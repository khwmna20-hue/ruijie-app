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
      title: 'Ruijie Device Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DeviceListScreen(),
    );
  }
}

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final String appId = 'openc3be644fb5dc';
  final String appSecret = '0dea886911864f359497a65f94164518';
  final String baseUrl = 'cloud-as.ruijienetworks.com';
  final String deviceSn = 'H1T0573003149'; // EG105GW-X Device SN

  bool isLoading = false;
  String rawResponseText = '';

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    setState(() {
      isLoading = true;
      rawResponseText = 'Connecting to Ruijie Cloud...';
    });

    try {
      // Step 1: Get Access Token
      final tokenUrl = Uri.https(
        baseUrl,
        '/service/api/oauth20/client/access_token',
        {'token': 'd63dss0a81e4415a889ac5b78fsc904a'},
      );

      final tokenResponse = await http.post(
        tokenUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appid': appId,
          'secret': appSecret,
        }),
      );

      final tokenData = json.decode(tokenResponse.body);
      final String? accessToken = tokenData['accessToken'] ?? tokenData['access_token'];

      if (accessToken == null) {
        setState(() {
          rawResponseText = 'Token Error:\n${tokenResponse.body}';
          isLoading = false;
        });
        return;
      }

      // Step 2: Fetch Device Info directly using SN
      final deviceUrl = Uri.https(
        baseUrl,
        '/service/api/maint/devices',
        {
          'access_token': accessToken,
          'sn': deviceSn,
        },
      );

      final deviceResponse = await http.get(deviceUrl);
      
      setState(() {
        rawResponseText = '--- TOKEN SUCCESS ---\nToken: $accessToken\nSN: $deviceSn\n\n--- DEVICE RESPONSE ---\nStatus: ${deviceResponse.statusCode}\nBody:\n${deviceResponse.body}';
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        rawResponseText = 'Exception Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruijie Device View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDevices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SelectableText(
                  rawResponseText,
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                ),
              ),
            ),
    );
  }
}
