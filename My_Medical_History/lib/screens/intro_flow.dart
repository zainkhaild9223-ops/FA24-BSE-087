import 'package:flutter/material.dart';
import '../drive_service.dart';
import '../main.dart' show Shell;
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.primary,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: const Icon(Icons.medical_services, size: 52, color: C.primary),
            ),
            const SizedBox(height: 24),
            const Text('My Medical History', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Your medical records, organized.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      );
}

const _pages = [
  (Icons.folder_shared_outlined, 'Keep Your Medical History Organized', 'Store visits, diagnoses, medicines and reports in one private place.'),
  (Icons.medical_services_outlined, 'Remember Every Doctor Visit', 'Doctor, hospital, diagnosis and medicines, all linked to every visit.'),
  (Icons.cloud_done_outlined, 'Your Records, Wherever You Need Them', 'Back up securely to your Google Drive and restore anytime.'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen> {
  final ctrl = PageController();
  int page = 0;

  void _next() {
    if (page < 2) {
      ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _skip();
    }
  }

  void _skip() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _skip, child: const Text('Skip'))),
            Expanded(
              child: PageView(
                controller: ctrl,
                onPageChanged: (v) => setState(() => page = v),
                children: [
                  for (final p in _pages)
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        IconBadge(p.$1, C.lav2, C.primary, 180),
                        const SizedBox(height: 32),
                        Text(p.$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text(p.$3, textAlign: TextAlign.center, style: const TextStyle(color: C.muted, height: 1.4)),
                      ]),
                    ),
                ],
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < 3; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(3),
                  width: page == i ? 22 : 8, height: 8,
                  decoration: BoxDecoration(color: page == i ? C.primary : C.lav2, borderRadius: BorderRadius.circular(8)),
                ),
            ]),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Btn(page == 2 ? 'Get Started' : 'Next', onTap: _next)),
            const SizedBox(height: 20),
          ]),
        ),
      );
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              const IconBadge(Icons.medical_services, C.primary, Colors.white, 84),
              const SizedBox(height: 20),
              const Text('My Medical History', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Sign in to securely manage your medical records.', textAlign: TextAlign.center, style: TextStyle(color: C.muted)),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 54,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final u = await DriveService.instance.signIn();
                      if (u != null && context.mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const DriveSetupScreen()));
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
                    }
                  },
                  icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF4285F4))),
                  label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: C.ink, side: const BorderSide(color: C.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.lock_outline, size: 14, color: C.muted),
                SizedBox(width: 6),
                Flexible(child: Text('Your records stay private and are never shared.', style: TextStyle(fontSize: 12, color: C.muted))),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      );
}

class DriveSetupScreen extends StatefulWidget {
  const DriveSetupScreen({super.key});
  @override
  State<DriveSetupScreen> createState() => _DriveSetupState();
}

class _DriveSetupState extends State<DriveSetupScreen> {
  int s = 0; // 0 idle, 1 connecting, 2 connected
  int restored = 0;

  Future<void> _connect() async {
    setState(() => s = 1);
    try {
      await DriveService.instance.ensureFolder();
      if (Store.instance.isEmpty) {
        final n = await Store.instance.restore(); // reinstall: bring old data back
        if (n > 0) restored = n;
      }
      if (mounted) setState(() => s = 2);
    } catch (e) {
      if (!mounted) return;
      setState(() => s = 0);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not connect Drive: $e')));
    }
  }

  void _home() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Shell()), (r) => false);

  Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(a, style: const TextStyle(color: C.muted, fontSize: 13)),
          Text(b, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              const IconBadge(Icons.add_to_drive_outlined, C.lav2, C.primary, 72),
              const SizedBox(height: 16),
              Text(s == 2 ? 'Google Drive Connected' : 'Connect Your Google Drive', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Keep a secure backup of your medical records in your Google Drive.', style: TextStyle(color: C.muted, height: 1.4)),
              const SizedBox(height: 20),
              Card2(
                child: Row(children: [
                  Avatar(DriveService.instance.user?.email ?? 'S', 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(DriveService.instance.user?.email ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(s == 2 ? '● Connected' : 'Google account', style: TextStyle(fontSize: 12, color: s == 2 ? C.green : C.muted, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  if (s == 2) const Icon(Icons.check_circle, color: C.green),
                ]),
              ),
              if (s == 2) ...[
                const SizedBox(height: 12),
                Card2(child: Column(children: [_row('Drive Folder', 'My Medical History'), _row('Sync Status', 'Everything is up to date'), _row('Backup', restored > 0 ? 'Restored $restored visits' : 'No backup found yet')])),
              ],
              const Spacer(),
              if (s == 0) Btn('Connect Google Drive', icon: Icons.cloud_upload_outlined, onTap: _connect),
              if (s == 1) const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 10), Text('Connecting...', style: TextStyle(color: C.muted))])),
              if (s == 2) Btn('Continue', onTap: _home),
              if (s != 2) Center(child: TextButton(onPressed: _home, child: const Text('Skip for Now'))),
            ]),
          ),
        ),
      );
}
