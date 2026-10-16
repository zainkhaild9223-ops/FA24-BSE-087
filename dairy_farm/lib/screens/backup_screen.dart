import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import '../common.dart';
import '../services/drive_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});
  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _drive = DriveService();
  GoogleSignInAccount? _user;
  List<BackupFile> _backups = [];
  bool _busy = false;
  String _busyText = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _user = await _drive.signInSilently();
      if (_user != null) await _loadBackups();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _loadBackups() async {
    try {
      _backups = await _drive.listBackups();
    } catch (e) {
      if (mounted) snack(context, 'Could not load backups: $e', error: true);
    }
  }

  Future<void> _run(String text, Future<void> Function() job, String done) async {
    setState(() {
      _busy = true;
      _busyText = text;
    });
    try {
      await job();
      await _loadBackups();
      if (mounted) snack(context, done);
    } catch (e) {
      if (mounted) snack(context, 'Error: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _signIn() async {
    try {
      final u = await _drive.signIn();
      if (u == null) return;
      _user = u;
      setState(() => _busy = true);
      await _loadBackups();
    } catch (e) {
      if (mounted) snack(context, 'Sign in failed: $e', error: true);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _restore(BackupFile f) async {
    final ok = await confirmDialog(
      context,
      'Restore from Cloud?',
      'This will replace ALL current local data with the backup "${f.name}". '
          'Unsaved changes will be lost. Continue?',
      yes: 'Replace & Restore',
      color: kAmber,
    );
    if (!ok) return;
    await _run('Restoring database...', () => _drive.restore(f.id),
        'Restore complete. Your data is back!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Stack(children: [
        ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Keep your records safe offline and in Google Drive cloud.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          _accountCard(),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _user == null || _busy
                ? null
                : () => _run('Uploading backup...', _drive.backup, 'Backup uploaded to Google Drive'),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Backup to Google Drive Now'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: _user == null || _busy || _backups.isEmpty
                ? null
                : () => _restore(_backups.first),
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Restore Latest Backup'),
          ),
          const SizedBox(height: 20),
          Row(children: [
            const Expanded(
                child: Text('Drive History',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            Text('${_backups.length} saved', style: const TextStyle(color: Colors.grey)),
          ]),
          if (_backups.isEmpty)
            const Padding(
                padding: EdgeInsets.only(top: 30),
                child: EmptyState(icon: Icons.cloud_off, text: 'No backups yet.')),
          ..._backups.map((f) => AppCard(
                child: Row(children: [
                  const Icon(Icons.insert_drive_file_outlined, color: kGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(f.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        '${f.created == null ? '' : DateFormat('dd MMM yyyy, hh:mm a').format(f.created!)}'
                        ' • ${(f.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ]),
                  ),
                  TextButton(
                      onPressed: _busy ? null : () => _restore(f),
                      child: const Text('Restore')),
                ]),
              )),
        ]),
        if (_busy)
          Container(
            color: Colors.black38,
            child: Center(
              child: AppCard(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(_busyText.isEmpty ? 'Please wait...' : _busyText),
                ]),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _accountCard() {
    if (_user == null) {
      return AppCard(
        child: Column(children: [
          const Icon(Icons.cloud_sync_outlined, size: 40, color: kGreen),
          const SizedBox(height: 8),
          const Text('Sign in with Google to backup your data'),
          const SizedBox(height: 10),
          ElevatedButton.icon(
              onPressed: _signIn,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google')),
        ]),
      );
    }
    return AppCard(
      child: Row(children: [
        const CircleAvatar(backgroundColor: kLightGreen, child: Icon(Icons.person, color: kGreen)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('GOOGLE DRIVE SYNC', style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text(_user!.email, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
        TextButton(
          onPressed: () async {
            await _drive.signOut();
            setState(() {
              _user = null;
              _backups = [];
            });
          },
          child: const Text('Sign out'),
        ),
      ]),
    );
  }
}
