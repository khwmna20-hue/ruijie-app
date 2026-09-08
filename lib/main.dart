import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RuijieDashboard(),
  ));
}

class RuijieDashboard extends StatelessWidget {
  const RuijieDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Myat Noe Aung - Ruijie Network'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAlignment.start,
                children: const [
                  ListTile(
                    leading: Icon(Icons.router, color: Colors.blue, size: 36),
                    title: Text(
                      'Wi-Fi Gateway (EG105GW-X)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('Status: Synced / Online', style: TextStyle(color: Colors.green)),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Serial Number (SN)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text('H1T0573003149', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  ListTile(
                    title: Text('Management IP', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text('192.168.1.23', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  ListTile(
                    title: Text('Egress Public IP', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text('129.224.203.154', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  ListTile(
                    title: Text('MAC Address', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text('E0:50:54:D9:81:31', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  ListTile(
                    title: Text('Firmware Version', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text('ReyeeOS 2.420.0.1910', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
