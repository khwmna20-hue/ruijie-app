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
      // Step 1: Fetch Access Token
      final tokenUrl = Uri.https(
        baseUrl,
        '/service/api/oauth20/client/access_token',
        {
          'app_id': appId,
          'app_secret': appSecret,
        },
      );

      final tokenResponse = await http.get(tokenUrl);
      if (tokenResponse.statusCode != 200) {
        setState(() {
          rawResponseText = 'Token Error: ${tokenResponse.body}';
          isLoading = false;
        });
        return;
      }

      final tokenData = json.decode(tokenResponse.body);
      final accessToken = tokenData['access_token'] ?? tokenData['data']?['access_token'];

      if (accessToken == null) {
        setState(() {
          rawResponseText = 'Token null in response: ${tokenResponse.body}';
          isLoading = false;
        });
        return;
      }

      // Step 2: Fetch Device List
      final deviceUrl = Uri.https(
        baseUrl,
        '/service/api/open/device/list',
        {'access_token': accessToken},
      );

      final deviceResponse = await http.get(deviceUrl);
      
      setState(() {
        rawResponseText = 'Status: ${deviceResponse.statusCode}\n\nResponse Body:\n${deviceResponse.body}';
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
        title: const Text('Ruijie Debug View'),
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
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
              ),
            ),
    );
  }
}
