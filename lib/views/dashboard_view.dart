import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'diagnostics_view.dart';
import 'connection_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFF38BDF8)),
            const SizedBox(width: 8),
            Text(provider.language == 'ar' ? 'لوحة القيادة' : 'AutoScan Dashboard', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          if (provider.isSimulator)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
              child: const Text('SIMULATOR', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          IconButton(
            icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
            onPressed: () {
              provider.disconnect();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ConnectionView()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RPM & Speed Hero Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _GaugeWidget(
                    title: provider.language == 'ar' ? 'سرعة المحرك' : 'RPM',
                    value: '${provider.rpm}',
                    unit: 'RPM',
                    color: const Color(0xFF38BDF8),
                    progress: provider.rpm / 8000,
                  ),
                  Container(width: 1, height: 80, color: Colors.white12),
                  _GaugeWidget(
                    title: provider.language == 'ar' ? 'السرعة' : 'Speed',
                    value: '${provider.speed}',
                    unit: 'km/h',
                    color: const Color(0xFF10B981),
                    progress: provider.speed / 220,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Secondary Metrics
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: provider.language == 'ar' ? 'حرارة المحرك' : 'Coolant Temp',
                    value: '${provider.coolantTemp}°C',
                    icon: Icons.thermostat_rounded,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: provider.language == 'ar' ? 'مستوى الوقود' : 'Fuel Level',
                    value: '${provider.fuelLevel}%',
                    icon: Icons.local_gas_station_rounded,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: provider.language == 'ar' ? 'وضع الخانق' : 'Throttle Pos',
                    value: '${provider.throttlePos}%',
                    icon: Icons.speed_rounded,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: provider.language == 'ar' ? 'حالة النظام' : 'ECU Status',
                    value: 'Normal',
                    icon: Icons.check_circle_outline_rounded,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Diagnostic Scan CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Computer Diagnostics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Scan your car ECU for Diagnostic Trouble Codes (DTCs), engine errors, and sensors.', style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticsView()));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.car_repair_rounded),
                      label: const Text('Run Full Diagnostic Scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeWidget extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final double progress;

  const _GaugeWidget({required this.title, required this.value, required this.unit, required this.color, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 8,
                backgroundColor: Colors.white10,
                color: color,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                Text(unit, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
