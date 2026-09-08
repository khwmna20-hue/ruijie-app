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

      // Step 2: Get Group List to retrieve groupId
      final groupUrl = Uri.https(
        baseUrl,
        '/service/api/maint/groups',
        {'access_token': accessToken},
      );

      final groupResponse = await http.get(groupUrl);
      final groupData = json.decode(groupResponse.body);

      String? groupId;
      if (groupData['data'] != null && (groupData['data'] as List).isNotEmpty) {
        groupId = groupData['data'][0]['id']?.toString() ?? groupData['data'][0]['groupId']?.toString();
      }

      // Step 3: Fetch Device List using groupId
      final Map<String, String> deviceParams = {'access_token': accessToken};
      if (groupId != null) {
        deviceParams['groupId'] = groupId;
      }

      final deviceUrl = Uri.https(
        baseUrl,
        '/service/api/maint/devices',
        deviceParams,
      );

      final deviceResponse = await http.get(deviceUrl);
      
      setState(() {
        rawResponseText = '--- SUCCESS! ---\nToken: $accessToken\nGroup ID: $groupId\n\n--- DEVICE LIST RESPONSE ---\n${deviceResponse.body}';
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
