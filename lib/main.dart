import 'package:flutter/material.dart';

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
  bool _isLoading = false;
  String _lastUpdated = 'Just now';

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for refresh animation
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    if (mounted) {
      setState(() {
        _isLoading = false;
        _lastUpdated = timeStr;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network status updated at $timeStr'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Text(
              'Myat Noe Aung',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Ruijie Cloud Monitor',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh Network Status',
            onPressed: _isLoading ? null : _handleRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Top Network Summary Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle,
                              color: Colors.green, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAlignment.start,
                          children: const [
                            Text(
                              'Network Status',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              'Healthy & Online',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAlignment.end,
                      children: [
                        const Text(
                          'Last Synced',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          _lastUpdated,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0066CC)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Device Detail Card
            Card(
              elevation: 2,
              shadowColor: Colors.black12,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.router,
                              color: Color(0xFF0066CC), size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAlignment.start,
                            children: [
                              const Text(
                                'Wi-Fi Gateway',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'EG105GW-X',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                ),
                                child: const Text(
                                  'Synced / Online',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(height: 1),
                    ),
                    _buildInfoRow(
                        Icons.pin, 'Serial Number (SN)', 'H1T0573003149'),
                    _buildInfoRow(
                        Icons.lan, 'Management IP', '192.168.1.23'),
                    _buildInfoRow(
                        Icons.public, 'Egress Public IP', '129.224.203.154'),
                    _buildInfoRow(
                        Icons.important_devices, 'MAC Address', 'E0:50:54:D9:81:31'),
                    _buildInfoRow(Icons.system_update_alt, 'Firmware Version',
                        'ReyeeOS 2.420.0.1910'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _handleRefresh,
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
