import 'dart:async';
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
      title: 'Ruijie Network Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Ruijie Cloud Credentials
  final String appId = 'openc3be644fb5dc';
  final String appSecret = '0dea886911864f359497a65f94164518';

  // Device Info
  String deviceName = 'Wi-Fi Gateway (EG105GW-X)';
  String status = 'Synced / Online';
  String serialNumber = 'H1T0573003149';
  String managementIp = '192.168.1.23';
  String publicIp = '129.224.203.154';
  String macAddress = 'E0:50:54:D9:81:31';
  String firmware = 'ReyeeOS 2.420.0.1910';

  bool _isSaving = false;

  // Ruijie Cloud မှ Access Token ရယူခြင်း
  Future<String?> _getAccessToken() async {
    final url = Uri.parse('https://cloud-asia.ruijienetworks.com/api/open/gettoken');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': appId,
          'appSecret': appSecret,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['accessToken'];
      }
    } catch (e) {
      debugPrint("Token Error: $e");
    }
    return null;
  }

  // Ruijie Cloud သို့ အချက်အလက်များ တိုက်ရိုက် လှမ်းပြင်ခြင်း
  Future<void> _updateRuijieCloud({
    required String newName,
    required String newIp,
    required String newPublicIp,
  }) async {
    setState(() {
      _isSaving = true;
    });

    final token = await _getAccessToken();

    if (token != null) {
      final updateUrl = Uri.parse('https://cloud-asia.ruijienetworks.com/api/open/device/update');
      try {
        final response = await http.post(
          updateUrl,
          headers: {
            'Content-Type': 'application/json',
            'accessToken': token,
          },
          body: jsonEncode({
            'sn': serialNumber,
            'deviceName': newName,
            'managementIp': newIp,
            'publicIp': newPublicIp,
          }),
        );

        final resData = jsonDecode(response.body);

        if (resData['code'] == 0) {
          _applyLocalChange(newName, newIp, newPublicIp, 'Ruijie Cloud သို့ တိုက်ရိုက် ပြင်ဆင်ပြီးပါပြီ');
        } else {
          _applyLocalChange(newName, newIp, newPublicIp, 'Permission Denied ဖြစ်နေပါသည် (Code: ${resData['code']})');
        }
      } catch (e) {
        _applyLocalChange(newName, newIp, newPublicIp, 'App ထဲတွင် ပြင်ဆင်ပြီးပါပြီ');
      }
    } else {
      _applyLocalChange(newName, newIp, newPublicIp, 'Cloud Token မရရှိသော်လည်း App UI တွင် ပြင်ဆင်ပြီးပါပြီ');
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _applyLocalChange(String newName, String newIp, String newPublicIp, String message) {
    setState(() {
      deviceName = newName;
      managementIp = newIp;
      publicIp = newPublicIp;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: deviceName);
    final ipController = TextEditingController(text: managementIp);
    final publicIpController = TextEditingController(text: publicIp);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ruijie Setting ပြင်ဆင်ရန်'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
              ),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: 'Management IP'),
              ),
              TextField(
                controller: publicIpController,
                decoration: const InputDecoration(labelText: 'Egress Public IP'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('မလုပ်တော့ပါ'),
            ),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _updateRuijieCloud(
                        newName: nameController.text,
                        newIp: ipController.text,
                        newPublicIp: publicIpController.text,
                      );
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cloud သို့ သိမ်းမည်'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Myat Noe Aung - Ruijie Sync'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          deviceName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF0066CC)),
                        onPressed: _showEditDialog,
                      ),
                    ],
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Management IP'),
                    subtitle: Text(managementIp),
                    leading: const Icon(Icons.lan),
                  ),
                  ListTile(
                    title: const Text('Egress Public IP'),
                    subtitle: Text(publicIp),
                    leading: const Icon(Icons.public),
                  ),
                  ListTile(
                    title: const Text('Serial Number'),
                    subtitle: Text(serialNumber),
                    leading: const Icon(Icons.pin),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEditDialog,
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Edit & Sync Cloud'),
      ),
    );
  }
}
