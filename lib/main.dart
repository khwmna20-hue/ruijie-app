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
      title: 'Ruijie Remote Manager',
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

  // Device & Wi-Fi Settings State
  String deviceName = 'Wi-Fi Gateway (EG105GW-X)';
  String serialNumber = 'H1T0573003149';
  String managementIp = '192.168.1.23';
  String wifiSsid = 'MyatNoe_Home_WiFi';
  String wifiPassword = 'password1234';

  bool _isSyncing = false;
  String _apiStatusMessage = 'Ruijie Cloud မ်ားႏွင့္ ခ်ိတ္ဆက္ရန္ အသင့္ရွိပါသည္';

  // ၁။ Ruijie Cloud Token ရယူခြင်း
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
        if (data['accessToken'] != null) {
          return data['accessToken'];
        }
      }
    } catch (e) {
      debugPrint('Token Request Error: $e');
    }
    return null;
  }

  // ၂။ ဆော့ဝဲလ်ထဲတွင် ပြင်လိုက်သည်နှင့် Ruijie Reyee သို့ တိုက်ရိုက် လှမ်းပြောင်းပေးသည့် Function
  Future<void> _updateRuijieSettings({
    required String newDeviceName,
    required String newIp,
    required String newSsid,
    required String newPassword,
  }) async {
    setState(() {
      _isSyncing = true;
      _apiStatusMessage = 'Ruijie Reyee သို့ အချက်အလက်များ လှမ်းပြောင်းနေပါသည်...';
    });

    final token = await _getAccessToken();

    if (token != null) {
      final updateUrl = Uri.parse('https://cloud-asia.ruijienetworks.com/api/open/device/config');
      try {
        final response = await http.post(
          updateUrl,
          headers: {
            'Content-Type': 'application/json',
            'accessToken': token,
          },
          body: jsonEncode({
            'sn': serialNumber,
            'deviceName': newDeviceName,
            'ip': newIp,
            'ssid': newSsid,
            'password': newPassword,
          }),
        );

        final resData = jsonDecode(response.body);

        if (resData['code'] == 0) {
          setState(() {
            deviceName = newDeviceName;
            managementIp = newIp;
            wifiSsid = newSsid;
            wifiPassword = newPassword;
            _apiStatusMessage = 'Ruijie Reyee ထဲတွင် အောင်မြင်စွာ ပြောင်းလဲသွားပါပြီ!';
          });
        } else if (resData['code'] == 5) {
          setState(() {
            deviceName = newDeviceName;
            managementIp = newIp;
            wifiSsid = newSsid;
            wifiPassword = newPassword;
            _apiStatusMessage = 'ဆော့ဝဲလ်တွင် ပြင်ပြီးပါပြီ (Ruijie Support မှ Write Permission ရသည်နှင့် Ruijie Reyee တွင်ပါ တိုက်ရိုက် ပြောင်းပါမည်)';
          });
        } else {
          setState(() {
            _apiStatusMessage = 'API Response: ${resData['msg'] ?? 'Code ${resData['code']}'}';
          });
        }
      } catch (e) {
        setState(() {
          deviceName = newDeviceName;
          managementIp = newIp;
          wifiSsid = newSsid;
          wifiPassword = newPassword;
          _apiStatusMessage = 'ဆော့ဝဲလ်တွင် အချက်အလက် ပြင်ဆင်ပြီးပါပြီ။';
        });
      }
    } else {
      setState(() {
        deviceName = newDeviceName;
        managementIp = newIp;
        wifiSsid = newSsid;
        wifiPassword = newPassword;
        _apiStatusMessage = 'ဆော့ဝဲလ်တွင် အချက်အလက် ပြင်ဆင်ပြီးပါပြီ။';
      });
    }

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_apiStatusMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: deviceName);
    final ipController = TextEditingController(text: managementIp);
    final ssidController = TextEditingController(text: wifiSsid);
    final passwordController = TextEditingController(text: wifiPassword);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ruijie Reyee အချက်အလက် ပြင်ရန်'),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                TextField(
                  controller: ssidController,
                  decoration: const InputDecoration(labelText: 'Wi-Fi Name (SSID)'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Wi-Fi Password'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('မလုပ်တော့ပါ'),
            ),
            ElevatedButton(
              onPressed: _isSyncing
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _updateRuijieSettings(
                        newDeviceName: nameController.text,
                        newIp: ipController.text,
                        newSsid: ssidController.text,
                        newPassword: passwordController.text,
                      );
                    },
              child: const Text('ပြင်မည် (Push to Ruijie)'),
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
        title: const Text('Ruijie Reyee Remote Controller'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Status Card
          Card(
            color: const Color(0xFFE6F0FA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  const Icon(Icons.sync, color: Color(0xFF0066CC)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _apiStatusMessage,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0066CC)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Device & WiFi Info Card
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
                        child: Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: [
                            Text(
                              deviceName,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Ruijie Reyee Device Configuration',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF0066CC)),
                        onPressed: _showEditDialog,
                        tooltip: 'ပြင်ဆင်မည်',
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(Icons.wifi, color: Color(0xFF0066CC)),
                    title: const Text('Wi-Fi Name (SSID)'),
                    subtitle: Text(wifiSsid),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.lock_outline, color: Color(0xFF0066CC)),
                    title: const Text('Wi-Fi Password'),
                    subtitle: Text(wifiPassword),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lan, color: Color(0xFF0066CC)),
                    title: const Text('Management IP'),
                    subtitle: Text(managementIp),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pin, color: Color(0xFF0066CC)),
                    title: const Text('Serial Number'),
                    subtitle: Text(serialNumber),
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
        icon: const Icon(Icons.edit),
        label: const Text('ဆော့ဝဲလ်ထဲတွင် ပြင်မည်'),
      ),
    );
  }
}
