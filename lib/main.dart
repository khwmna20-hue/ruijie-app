import 'package:flutter/material.dart';

void main() {
  runApp(const RuijieApp());
}

class RuijieApp extends StatelessWidget {
  const RuijieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruijie Cloud Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
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
  bool isLoading = false;

  // Real Device Data from Ruijie Cloud Portal
  final Map<String, dynamic> deviceData = {
    'name': 'Wi-Fi Gateway',
    'model': 'EG105GW-X',
    'sn': 'H1T0573003149',
    'status': 'Synced',
    'group': 'Myat Noe Aung',
    'mgmtIp': '192.168.1.23',
    'egressIp': '129.224.203.154',
    'firmware': 'ReyeeOS 2.420.0.1910',
    'mac': 'E0:50:54:D9:81:31',
    'type': 'Gateway',
    'isOnline': true,
  };

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device status updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: const [
            Text(
              'Myat Noe Aung',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black80,
              ),
            ),
            Text(
              'Ruijie Cloud Network',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAlignment.start,
                  children: [
                    // Overview Category Cards
                    _buildSummaryRow(),
                    const SizedBox(height: 20),

                    const Text(
                      'Connected Devices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black70,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Main Device Card
                    _buildDeviceCard(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _buildStatCard('All', '1', Colors.blue),
        const SizedBox(width: 8),
        _buildStatCard('Gateway', '1', Colors.green),
        const SizedBox(width: 8),
        _buildStatCard('Switch', '0', Colors.orange),
        const SizedBox(width: 8),
        _buildStatCard('AP', '0', Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            // Header Row: Icon, Name & Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.router, color: Colors.blue, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAlignment.start,
                    children: [
                      Text(
                        deviceData['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Model: ${deviceData['model']}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        deviceData['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),

            // Device Info Grid
            _buildInfoRow(Icons.pin, 'Serial Number (SN)', deviceData['sn']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.lan, 'Management IP', deviceData['mgmtIp']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.public, 'Egress Public IP', deviceData['egressIp']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.memory, 'MAC Address', deviceData['mac']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.system_update_alt, 'Firmware', deviceData['firmware']),

            const SizedBox(height: 16),

            // Details Action Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showDeviceDetails(context),
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('View Full Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  void _showDeviceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Device Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.group_work, color: Colors.blue),
                title: const Text('Project Group'),
                subtitle: Text(deviceData['group']),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Config Status'),
                subtitle: const Text('Synced with Ruijie Cloud'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield, color: Colors.purple),
                title: const Text('Model Type'),
                subtitle: const Text('Enterprise Gateway / Router'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
