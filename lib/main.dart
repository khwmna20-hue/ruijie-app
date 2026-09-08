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
      home: const RuijieRealDataPage(),
    );
  }
}

// ==========================================
// RUIJIE API SERVICE (REAL DATA ONLY)
// ==========================================
class RuijieApiService {
  static const String baseUrl = 'https://cloud-asia.ruijienetworks.com/api/open';
  static const String appId = 'openc3be644fb5dc';
  static const String appSecret = '0dea886911864f359497a65f94164518';

  static Future<String> getAccessToken() async {
    final response = await http.post(
      Uri.parse('$baseUrl/gettoken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'appId': appId, 'appSecret': appSecret}),
    );

    final resJson = jsonDecode(response.body);

    if (resJson['code'] != 0 && resJson['code'] != '0') {
      throw Exception('Ruijie Token Error [Code ${resJson['code']}]: ${resJson['msg']}');
    }

    return resJson['accessToken'] ?? resJson['data']?['accessToken'] ?? '';
  }

  static Future<List<dynamic>> getConnectedClients(String sn) async {
    final token = await getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/device/clientList'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accessToken': token,
        'sn': sn,
      }),
    );

    final resJson = jsonDecode(response.body);

    if (resJson['code'] != 0 && resJson['code'] != '0') {
      throw Exception('Ruijie API Error [Code ${resJson['code']}]: ${resJson['msg']}');
    }

    final data = resJson['data'];
    if (data is List) return data;
    if (data is Map && data['list'] is List) return data['list'];

    return [];
  }
}

// ==========================================
// REAL UI DISPLAY
// ==========================================
class RuijieRealDataPage extends StatefulWidget {
  const RuijieRealDataPage({super.key});

  @override
  State<RuijieRealDataPage> createState() => _RuijieRealDataPageState();
}

class _RuijieRealDataPageState extends State<RuijieRealDataPage> {
  final String routerSn = 'H1T0573003149';
  late Future<List<dynamic>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _clientsFuture = RuijieApiService.getConnectedClients(routerSn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruijie Real Data Monitor'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Ruijie Cloud သို့ Real Data လှမ်းတောင်းနေသည်...'),
                ],
              ),
            );
          }

          // 2. Server Error State (e.g. Code 5 Permission Denied)
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Ruijie Server အကြောင်းပြန်ချက် (Error):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${snapshot.error}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('ပြန်လည်ကြိုးစားမည်'),
                    ),
                  ],
                ),
              ),
            );
          }

          final clients = snapshot.data ?? [];

          // 3. Empty Data State
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phonelink_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('SN: $routerSn ထဲတွင် လက်ရှိ ချိတ်ဆက်ထားသော ဖုန်း/Device မရှိပါ။'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Refresh လုပ်မည်'),
                  ),
                ],
              ),
            );
          }

          // 4. Real Data Success State
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final item = clients[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.phone_android, color: Color(0xFF0066CC)),
                  title: Text(item['hostname'] ?? item['name'] ?? item['ip'] ?? 'Device'),
                  subtitle: Text('IP: ${item['ip'] ?? '-'} | MAC: ${item['mac'] ?? '-'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
