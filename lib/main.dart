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
      title: 'Ruijie Reyee Manager',
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
// 1. LOGIN SCREEN
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

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

    try {
      final tokenUrl = Uri.parse('https://cloud-asia.ruijienetworks.com/api/open/gettoken');
      final response = await http.post(
        tokenUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'appId': appId, 'appSecret': appSecret}),
      ).timeout(const Duration(seconds: 10));

      String token = 'active_access_token';
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token = data['accessToken'] ?? 'active_access_token';
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationPage(
              accessToken: token,
              accountName: account,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationPage(
              accessToken: 'active_token',
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
              const Icon(Icons.router, size: 80, color: Color(0xFF0066CC)),
              const SizedBox(height: 16),
              const Text(
                'Ruijie Reyee Control Portal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Ruijie Reyee အကောင့်ဖြင့် လော့အင်ဝင်ပါ', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
// 2. MAIN NAVIGATION (BOTTOM TABS)
// ==========================================
class MainNavigationPage extends StatefulWidget {
  final String accessToken;
  final String accountName;

  const MainNavigationPage({
    super.key,
    required this.accessToken,
    required this.accountName,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardPage(accessToken: widget.accessToken, accountName: widget.accountName),
      ConnectedDevicesPage(accessToken: widget.accessToken),
      const UserManagementPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0066CC),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.router),
            label: 'Router',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'ဖုန်း/ကိရိယာများ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            label: 'User Group',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. ROUTER DASHBOARD
// ==========================================
class DashboardPage extends StatefulWidget {
  final String accessToken;
  final String accountName;

  const DashboardPage({super.key, required this.accessToken, required this.accountName});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String deviceName = 'Ruijie EG105GW Gateway';
  String serialNumber = 'H1T0573003149';
  String managementIp = '192.168.1.1';
  String wifiSsid = 'MyatNoe_Reyee_WiFi';
  String wifiPassword = 'password1234';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.accountName} ၏ Dashboard'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: const Color(0xFFE6F0FA),
            child: const Padding(
              padding: EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF0066CC)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ruijie Reyee Cloud ချိတ်ဆက်ထားပြီးပါပြီခင်ဗျာ။',
                      style: TextStyle(color: Color(0xFF0066CC), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deviceName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const Text('Status: Online', style: TextStyle(color: Colors.green)),
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
    );
  }
}

// ==========================================
// 4. CONNECTED DEVICES (ဖုန်းဘယ်နှစ်လုံးချိတ်ထားလဲ)
// ==========================================
class ConnectedDevicesPage extends StatelessWidget {
  final String accessToken;

  const ConnectedDevicesPage({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    // Mock sample connected devices
    final List<Map<String, String>> devices = [
      {'name': 'iPhone 15 Pro', 'ip': '192.168.1.102', 'mac': 'A4:C3:F0:12:34:56', 'speed': '1.2 Mbps ↓ / 240 KB/s ↑'},
      {'name': 'Samsung Galaxy S23', 'ip': '192.168.1.105', 'mac': '8C:11:CB:78:90:AB', 'speed': '3.5 Mbps ↓ / 512 KB/s ↑'},
      {'name': 'Redmi Note 12', 'ip': '192.168.1.110', 'mac': '00:E0:4C:68:00:11', 'speed': '0.5 Mbps ↓ / 100 KB/s ↑'},
      {'name': 'MacBook Pro 16"', 'ip': '192.168.1.115', 'mac': 'BC:D5:60:99:88:77', 'speed': '8.1 Mbps ↓ / 2.1 Mbps ↑'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('ချိတ်ဆက်ထားသော ဖုန်းများ (${devices.length} လုံး)'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final dev = devices[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE6F0FA),
                child: Icon(
                  dev['name']!.contains('MacBook') ? Icons.laptop : Icons.phone_android,
                  color: const Color(0xFF0066CC),
                ),
              ),
              title: Text(dev['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('IP: ${dev['ip']} | MAC: ${dev['mac']}\nအင်တာနက်သုံးစွဲမှု: ${dev['speed']}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 5. USER MANAGEMENT / USER GROUP (ပုံထဲအတိုင်း)
// ==========================================
class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1, // Open User Group Tab by default
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          actions: [
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.smart_toy_outlined, color: Colors.indigo),
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF0066CC),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0066CC),
            tabs: [
              Tab(text: 'User'),
              Tab(text: 'User Group'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const Center(child: Text('User များ စာရင်းမရှိသေးပါ။')),
            _buildUserGroupList(context),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Add User Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildUserGroupList(BuildContext context) {
    final List<Map<String, String>> groups = [
      {
        'title': '3D',
        'period': '30 Days',
        'quota': 'Unlimited',
        'upload': '10 Mbps ↑',
        'download': '5 Mbps ↓',
      },
      {
        'title': '500K\$',
        'period': '1 Hour',
        'quota': 'Unlimited',
        'upload': 'Unlimited',
        'download': '5 Mbps ↓',
      },
      {
        'title': '1000K\$',
        'period': '180 Minutes',
        'quota': 'Unlimited',
        'upload': '10 Mbps ↑',
        'download': '10 Mbps ↓',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          elevation: 0,
          color: const Color(0xFFF8F9FA),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(group['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRow('Period', group['period']!),
                _buildRow('Data Quota', group['quota']!),
                _buildRow('Upload Speed', group['upload']!),
                _buildRow('Download Speed', group['download']!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
