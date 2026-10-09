import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'data.dart';
import 'drive_service.dart';

String _s(Map v, String k) => '${v[k] ?? ''}';
List _l(Map v, String k) => (v[k] as List?) ?? const [];

/// Local storage = one JSON file on the phone (medical_history.json).
/// The same file is auto-uploaded to the user's Google Drive and can be restored from it.
class Store extends ChangeNotifier {
  Store._();
  static final instance = Store._();
  static const fileName = 'medical_history.json';

  List<Map<String, dynamic>> _visits = []; // newest first
  DateTime? lastSynced;
  String status = 'idle'; // idle | syncing | done | failed | signedout

  bool get isEmpty => _visits.isEmpty;

  String get lastSyncedText {
    final t = lastSynced;
    if (t == null) return 'Not synced yet';
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return 'Today, $h:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  Future<File> _file() async => File('${(await getApplicationDocumentsDirectory()).path}/$fileName');

  Future<void> load() async {
    try {
      final f = await _file();
      if (await f.exists()) _fromJson(jsonDecode(await f.readAsString()));
    } catch (_) {}
    notifyListeners();
  }

  void _fromJson(dynamic j) {
    final m = j as Map;
    _visits = [for (final v in (m['visits'] as List)) Map<String, dynamic>.from(v as Map)];
  }

  String toJson() => jsonEncode({'app': 'My Medical History', 'updatedAt': DateTime.now().toIso8601String(), 'visits': _visits});

  Future<void> _save() async => (await _file()).writeAsString(toJson());

  Future<void> addVisit(Map<String, dynamic> v) async {
    v['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    _visits.insert(0, v);
    await _save();
    notifyListeners();
    autoSync(); // background, not awaited
  }

  /// Automatic Drive sync (silent: never shows a login popup).
  Future<void> autoSync() async {
    if (DriveService.instance.user == null && !await DriveService.instance.trySilent()) {
      status = 'signedout';
      notifyListeners();
      return;
    }
    await syncNow();
  }

  Future<String> syncNow() async {
    status = 'syncing';
    notifyListeners();
    try {
      await DriveService.instance.uploadText(fileName, toJson());
      lastSynced = DateTime.now();
      status = 'done';
      notifyListeners();
      return 'Backup saved to your Google Drive';
    } catch (e) {
      status = 'failed';
      notifyListeners();
      return 'Sync failed: $e';
    }
  }

  /// Returns number of visits restored, or -1 if there is no backup in Drive.
  Future<int> restore() async {
    final txt = await DriveService.instance.downloadText(fileName);
    if (txt == null) return -1;
    _fromJson(jsonDecode(txt));
    await _save();
    lastSynced = DateTime.now();
    status = 'done';
    notifyListeners();
    return _visits.length;
  }

  // ---- views used by the existing screens ----
  List<Doc> get docs {
    final counts = <String, int>{};
    for (final v in _visits) {
      counts[_s(v, 'doctor')] = (counts[_s(v, 'doctor')] ?? 0) + 1;
    }
    final out = <String, Doc>{};
    for (final v in _visits) {
      final n = _s(v, 'doctor');
      out.putIfAbsent(n, () => Doc(n, _s(v, 'spec'), _s(v, 'hospital'), _s(v, 'phone'), counts[n]!));
    }
    return out.values.toList();
  }

  List<Visit> get visits => [
        for (final v in _visits)
          Visit(_s(v, 'date'), _s(v, 'doctor'), _s(v, 'hospital'), _s(v, 'dx'), _l(v, 'meds').length, _l(v, 'tests').length, _l(v, 'files').length)
      ];

  List<Med> get meds {
    final order = <String>[];
    final first = <String, Map<String, String>>{};
    final count = <String, int>{};
    for (final v in _visits) {
      for (final m in _l(v, 'meds')) {
        final n = _s(m as Map, 'name');
        if (n.isEmpty) continue;
        count[n] = (count[n] ?? 0) + 1;
        if (!first.containsKey(n)) {
          first[n] = {'dose': _s(m, 'dose'), 'last': _s(v, 'date'), 'doc': _s(v, 'doctor')};
          order.add(n);
        }
      }
    }
    return [for (final n in order) Med(n, first[n]!['dose']!, first[n]!['last']!, first[n]!['doc']!, count[n]!)];
  }

  List<(String, String, String)> get usage => [
        for (final v in _visits)
          for (final m in _l(v, 'meds')) (_s(v, 'date'), _s(v, 'doctor'), '${_s(m as Map, 'name')} ${_s(m, 'dose')}'.trim())
      ];

  List<Rep> get reps => [
        for (final v in _visits)
          for (final f in _l(v, 'files'))
            Rep(_s(f as Map, 'name'), _s(v, 'date'), _s(v, 'doctor'), _s(v, 'hospital'), 'Other', _s(f, 'name').toLowerCase().endsWith('.pdf') ? 'PDF' : 'JPG')
      ];
}
