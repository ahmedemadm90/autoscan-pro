import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'dashboard_view.dart';

class ConnectionView extends StatelessWidget {
  const ConnectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AutoScan Pro', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('OBD-II Vehicle Diagnostic System', style: TextStyle(color: Colors.white60, fontSize: 14)),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      provider.setLanguage(provider.language == 'en' ? 'ar' : 'en');
                    },
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                      child: Text(provider.language.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.bluetooth_searching_rounded, size: 64, color: Color(0xFF38BDF8)),
                    const SizedBox(height: 16),
                    const Text('Connect ELM327 Adapter', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Plug your OBD-II Bluetooth adapter into your car port and turn on the ignition.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.scanning ? null : () async {
                          await provider.scanForAdapters();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: provider.scanning ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search_rounded),
                        label: Text(provider.scanning ? 'Scanning...' : 'Scan Bluetooth Adapters', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: provider.connecting ? null : () async {
                          await provider.connectToDevice(null);
                          if (context.mounted) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardView()));
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.play_circle_outline_rounded, color: Color(0xFF38BDF8)),
                        label: const Text('Start Simulator Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Available Devices', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: provider.devices.isEmpty
                    ? const Center(child: Text('No devices found. Use Simulator Mode or scan again.', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: provider.devices.length,
                        itemBuilder: (context, index) {
                          final device = provider.devices[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              title: Text(device.platformName.isNotEmpty ? device.platformName : 'Unknown OBD Device', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(device.remoteId.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              trailing: FilledButton(
                                onPressed: () async {
                                  await provider.connectToDevice(device);
                                  if (context.mounted) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardView()));
                                  }
                                },
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
                                child: const Text('Connect'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
