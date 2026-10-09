import 'package:flutter/material.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class BackupSyncScreen extends StatefulWidget {
  const BackupSyncScreen({super.key});
  @override
  State<BackupSyncScreen> createState() => _BackupSyncScreenState();
}

class _BackupSyncScreenState extends State<BackupSyncScreen> {
  bool wifi = true, cellular = false, syncing = false;

  Future<void> _sync() async {
    if (syncing) return;
    setState(() => syncing = true);
    final msg = await Store.instance.syncNow();
    if (!mounted) return;
    setState(() => syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(12), children: [
        const Row(children: [
          IconBadge(Icons.medical_services, C.primary, Colors.white, 30),
          SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Medical History', style: TextStyle(fontWeight: FontWeight.w800, color: C.primary)),
            Text('Settings', style: TextStyle(fontSize: 10, color: C.muted)),
          ]),
          Spacer(),
          Pill('Encrypted', C.mint, C.green, icon: Icons.lock_outline),
        ]),
        const SizedBox(height: 14),
        const Text('Backup & Sync', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const Text('CLOUD DATA GUARDIAN', style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w700, color: C.primary)),
        const SizedBox(height: 12),
        Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.cloud_outlined, size: 16, color: C.muted), SizedBox(width: 6),
              Expanded(child: Text('Google Drive Cloud Vault', style: TextStyle(fontSize: 12, color: C.muted))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Avatar('S', 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('sarah.jenkins@gmail.com', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text('● Connected • Active Sync', style: TextStyle(fontSize: 11, color: C.green, fontWeight: FontWeight.w600)),
                ]),
              ),
              TextButton(onPressed: () {}, child: const Text('Switch')),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFD9FBEA), borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                IconBadge(Icons.check, C.green, Colors.white, 34),
                SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Everything is up to date', style: TextStyle(fontWeight: FontWeight.w700, color: C.green)),
                    Text('Last synchronized: Today, 10:32 AM', style: TextStyle(fontSize: 11, color: C.green)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            const Row(children: [
              Expanded(child: Text('Vault Footprint', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Text('24.8 MB of 15 GB Used', style: TextStyle(fontSize: 11, color: C.muted)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(height: 8, child: Row(children: [
                Expanded(flex: 50, child: Container(color: C.primary)),
                Expanded(flex: 30, child: Container(color: C.green)),
                Expanded(flex: 20, child: Container(color: const Color(0xFF7C86E8))),
                Expanded(flex: 200, child: Container(color: C.lav2)),
              ])),
            ),
            const SizedBox(height: 6),
            const Wrap(spacing: 12, children: [
              Text('● Rx Prescriptions (14%)', style: TextStyle(fontSize: 10, color: C.primary)),
              Text('● Labs (8%)', style: TextStyle(fontSize: 10, color: C.green)),
              Text('● Visits (4%)', style: TextStyle(fontSize: 10, color: Color(0xFF7C86E8))),
            ]),
            const SizedBox(height: 12),
            Btn(syncing ? 'Syncing...' : 'Sync Now', icon: Icons.sync, onTap: _sync),
          ]),
        ),
        const SizedBox(height: 12),
        Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.autorenew, color: C.primary, size: 18), SizedBox(width: 8),
              Expanded(child: Text('Auto-Sync Rules', style: TextStyle(fontWeight: FontWeight.w700))),
              Text('Background Daemon', style: TextStyle(fontSize: 10, color: C.muted)),
            ]),
            const SizedBox(height: 10),
            _Rule(Icons.wifi, 'Auto-Sync on Wi-Fi', 'Automatically back up new visits, prescriptions, and lab tests immediately', wifi, (v) => setState(() => wifi = v)),
            const Divider(height: 20),
            _Rule(Icons.signal_cellular_alt, 'Sync Over Cellular Data', 'May consume mobile data plan for heavy document scans', cellular, (v) => setState(() => cellular = v)),
          ]),
        ),
        const SizedBox(height: 12),
        const Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.shield_outlined, color: C.primary, size: 18), SizedBox(width: 8),
              Expanded(child: Text('Connection Diagnostics', style: TextStyle(fontWeight: FontWeight.w700))),
              Text('Live Status', style: TextStyle(fontSize: 10, color: C.muted)),
            ]),
            SizedBox(height: 4),
            Text('Demonstrating mobile telemetry and edge state safeguards:', style: TextStyle(fontSize: 11, color: C.muted)),
            SizedBox(height: 10),
            _Diag(Icons.cloud_sync_outlined, 'Cloud Handshake', 'Matching local data/package deltas', 'Syncing...', C.lav2, C.ink),
            SizedBox(height: 8),
            _Diag(Icons.verified_user_outlined, 'Checksum Integrity', 'SHA-256 match verified', 'Sync Successful', C.mint, C.green),
            SizedBox(height: 8),
            _Diag(Icons.wifi_off, 'Offline Resilience Buffer', 'Changes saved locally on device. Will auto-sync when connection returns.', 'Offline Mode', C.lav2, C.ink),
          ]),
        ),
        const SizedBox(height: 12),
        Card2(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.folder_outlined, color: C.primary, size: 18), SizedBox(width: 8),
              Text('Data Management & Recovery', style: TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            _Action(Icons.ios_share, 'Export Complete Medical Vault', 'Encrypted ZIP package • Printable PDF Summary'),
            const SizedBox(height: 8),
            _Action(Icons.restore, 'Restore From Earlier Backup', 'Select historical snapshot timestamp from Google Drive'),
          ]),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
          child: const Row(children: [
            Icon(Icons.lock_outline, size: 14, color: C.primary), SizedBox(width: 8),
            Expanded(child: Text('End-to-end encrypted backup. Your health records and diagnoses are encrypted on-device with AES-256 before leaving. Your medical data remains strictly private.', style: TextStyle(fontSize: 10.5))),
          ]),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _Rule extends StatelessWidget {
  final IconData i;
  final String t, s;
  final bool v;
  final ValueChanged<bool> on;
  const _Rule(this.i, this.t, this.s, this.v, this.on);
  @override
  Widget build(BuildContext context) => Row(children: [
        IconBadge(i, C.lav2, C.primary, 34),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(s, style: const TextStyle(fontSize: 11, color: C.muted)),
          ]),
        ),
        Switch(value: v, onChanged: on, activeColor: Colors.white, activeTrackColor: C.primary),
      ]);
}

class _Diag extends StatelessWidget {
  final IconData i;
  final String t, s, tag;
  final Color bg, fg;
  const _Diag(this.i, this.t, this.s, this.tag, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(i, size: 20, color: C.primary), const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              Text(s, style: const TextStyle(fontSize: 10.5, color: C.muted)),
            ]),
          ),
          Pill(tag, bg, fg),
        ]),
      );
}

class _Action extends StatelessWidget {
  final IconData i;
  final String t, s;
  const _Action(this.i, this.t, this.s);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: C.lav, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          IconBadge(i, C.lav2, C.primary, 34), const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(s, style: const TextStyle(fontSize: 10.5, color: C.muted)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: C.muted),
        ]),
      );
}
