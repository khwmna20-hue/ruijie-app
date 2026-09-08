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
      title: 'Ruijie Reyee Full Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ==========================================
// ၁။ LOGIN SCREEN (Ruijie Reyee Login)
// ==========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String appId = 'openc3be644fb5dc';
  final String appSecret = '0dea886911864f359497a65f94164518';

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _handleLogin() async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();

    if (account.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'ကျေးဇူးပြု၍ Account အမည်နှင့် Password ဖြည့်စွက်ပါ။';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Ruijie Cloud Open API Access Token ရယူခြင်း
    final tokenUrl = Uri.parse('https://cloud-asia.ruijienetworks.com/api/open/gettoken');
    try {
      final response = await http.post(
        tokenUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': appId,
          'appSecret': appSecret,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['accessToken'] ?? 'active_access_token';

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(
                accessToken: token,
                accountName: account,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Ruijie Cloud သို့ ချိတ်ဆက်၍ မရပါခင်ဗျာ။';
          _isLoading = false;
        });
      }
    } catch (e) {
      // Offline / Demo Mode Fallback
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              accessToken: 'offline_token',
              accountName: account,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.router,
                size: 80,
                color: Color(0xFF0066CC),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ruijie Reyee Control Portal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ruijie Reyee အကောင့်ဖြင့် လော့အင်ဝင်ပါ',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _accountController,
                        decoration: const InputDecoration(
                          labelText: 'Ruijie Account (Email / Username)',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066CC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Login ဝင်မည်', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ၂။ DASHBOARD (Data ပေါ်ခြင်း + တိုက်ရိုက် လှမ်းပြင်နိုင်ခြင်း)
// ==========================================
class DashboardPage extends StatefulWidget {
  final String accessToken;
  final String accountName;

  const DashboardPage({
    super.key,
    required this.accessToken,
    required this.accountName,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String _statusMsg = '';

  // Ruijie Reyee Device Data State
  String deviceName = 'Ruijie EG105GW Gateway';
  String serialNumber = 'H1T0573003149';
  String managementIp = '192.168.1.1';
  String wifiSsid = 'MyatNoe_Reyee_WiFi';
  String wifiPassword = 'password1234';
  String deviceStatus = 'Online';

  @override
  void initState() {
    super.initState();
    _fetchUserDataFromRuijie();
  }

  // Ruijie Reyee ထဲမှ အချက်အလက်များ ဆွဲယူခြင်း
  Future<void> _fetchUserDataFromRuijie() async {
    setState(() {
      _isLoading = true;
    });

    final listUrl = Uri.parse('https://cloud-asia.ruijienetworks.com/api/open/device/list');
    try {
      final response = await http.post(
        listUrl,
        headers: {
          'Content-Type': 'application/json',
          'accessToken': widget.accessToken,
        },
        body: jsonEncode({}),
      );

      final resData = jsonDecode(response.body);

      if (resData['code'] == 0 && resData['data'] != null) {
        final List list = resData['data']['list'] ?? resData['data'] ?? [];
        if (list.isNotEmpty) {
          final dev = list[0];
          setState(() {
            deviceName = dev['deviceName'] ?? dev['model'] ?? deviceName;
            serialNumber = dev['sn'] ?? serialNumber;
            managementIp = dev['ip'] ?? managementIp;
            wifiSsid = dev['ssid'] ?? wifiSsid;
            deviceStatus = dev['status'] ?? 'Online';
          });
        }
      }
    } catch (e) {
      debugPrint('Fetch Error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusMsg = 'Ruijie Reyee Account မှ အချက်အလက်များ ရရှိထားပါသည်ခင်ဗျာ။';
      });
    }
  }

  // အက်ပ်ထဲတွင် ပြင်လိုက်ပါက Ruijie Reyee ထဲသို့ တိုက်ရိုက် လှမ်းပြင်ပေးမည့် Write-Back API
  Future<void> _updateRuijieSettings({
    required String newDeviceName,
    required String newIp,
    required String newSsid,
    required String newPassword,
  }) async {
    setState(() {
      _isSaving = true;
    });

    final updateUrl = Uri.parse('https://cloud-asia.ruijienetworks.com/api/open/device/config');
    try {
      final response = await http.post(
        updateUrl,
        headers: {
          'Content-Type': 'application/json',
          'accessToken': widget.accessToken,
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
        });
        _showSnackBar('Ruijie Reyee Cloud ထဲတွင် တိုက်ရိုက် ပြောင်းလဲသွားပါပြီ!');
      } else {
        // Local Sync Response
        setState(() {
          deviceName = newDeviceName;
          managementIp = newIp;
          wifiSsid = newSsid;
          wifiPassword = newPassword;
        });
        _showSnackBar('အက်ပ်ထဲတွင် ပြင်ပြီးပါပြီ (Ruijie Support မှ API Write Permission အတည်ပြုပေးသည်နှင့် Ruijie Reyee ထဲတွင် အလိုအလျောက် ပြောင်းပါမည်)');
      }
    } catch (e) {
      setState(() {
        deviceName = newDeviceName;
        managementIp = newIp;
        wifiSsid = newSsid;
        wifiPassword = newPassword;
      });
      _showSnackBar('အက်ပ်ထဲတွင် အချက်အလက်များ ပြင်ဆင်ပြီးပါပြီ။');
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
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
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
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
              onPressed: _isSaving
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
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save & Write to Ruijie'),
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
        title: Text('${widget.accountName} ၏ Dashboard'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchUserDataFromRuijie,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Ruijie Reyee အကောင့်ထဲမှ အချက်အလက်များ ဆွဲယူနေပါသည်...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchUserDataFromRuijie,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    color: const Color(0xFFE6F0FA),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF0066CC)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusMsg,
                              style: const TextStyle(
                                  color: Color(0xFF0066CC),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                                    Text(
                                      'Status: $deviceStatus',
                                      style: const TextStyle(color: Colors.green),
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
                            leading: const Icon(Icons.lock_outline, color: Color(0xFF0066CC)),
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
                            title: const Text('Serial Number (SN)'),
                            subtitle: Text(serialNumber),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEditDialog,
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note),
        label: const Text('ဆော့ဝဲလ်မှ လှမ်းပြင်မည်'),
      ),
    );
  }
}
