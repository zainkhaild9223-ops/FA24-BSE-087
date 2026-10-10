import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'data.dart';
import 'drive_service.dart';

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
DateTime? parseDate(String s) {
  final p = s.split(' ');
  if (p.length != 3) return null;
  final m = _mon.indexOf(p[1]);
  final d = int.tryParse(p[0]);
  final y = int.tryParse(p[2]);
  if (m < 0 || d == null || y == null) return null;
  return DateTime(y, m + 1, d);
}

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
  Map<String, String> profile = {}; // signed-in Google user (name, email, photo)

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
    try {
      final pf = File('${(await getApplicationDocumentsDirectory()).path}/profile.json');
      if (await pf.exists()) profile = Map<String, String>.from(jsonDecode(await pf.readAsString()) as Map);
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
    final u = DriveService.instance.user;
    if (u != null) await setProfile(u.displayName ?? '', u.email, u.photoUrl);
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

  // ---- profile / raw access ----
  String get firstName => (profile['name'] ?? '').trim().split(' ').first;

  Future<void> setProfile(String name, String email, String? photo) async {
    profile = {'name': name.isEmpty ? email.split('@').first : name, 'email': email, 'photo': photo ?? ''};
    try {
      await File('${(await getApplicationDocumentsDirectory()).path}/profile.json').writeAsString(jsonEncode(profile));
    } catch (_) {}
    notifyListeners();
  }

  List<Map<String, dynamic>> get raw => _visits;

  Future<void> deleteVisit(String id) async {
    _visits.removeWhere((v) => '${v['id']}' == id);
    await _save();
    notifyListeners();
    autoSync();
  }

  /// Nearest follow-up date that is today or in the future.
  Map<String, String>? get upcoming {
    final now = DateTime.now();
    final t0 = DateTime(now.year, now.month, now.day);
    Map<String, dynamic>? best;
    DateTime? bd;
    for (final v in _visits) {
      final d = parseDate(_s(v, 'followUp'));
      if (d == null || d.isBefore(t0)) continue;
      if (bd == null || d.isBefore(bd)) {
        bd = d;
        best = v;
      }
    }
    if (best == null || bd == null) return null;
    final n = bd.difference(t0).inDays;
    return {
      'doctor': _s(best, 'doctor'), 'spec': _s(best, 'spec'), 'hospital': _s(best, 'hospital'), 'date': _s(best, 'followUp'),
      'in': n == 0 ? 'Today' : n == 1 ? 'Tomorrow' : 'In $n days',
    };
  }

  /// Search doctors, diagnosis, hospitals, medicines and tests. Returns (visit index, what matched).
  List<(int, String)> search(String q) {
    final k = q.toLowerCase();
    final out = <(int, String)>[];
    for (var i = 0; i < _visits.length; i++) {
      final v = _visits[i];
      String? hit;
      if (_s(v, 'doctor').toLowerCase().contains(k)) {
        hit = _s(v, 'doctor');
      } else if (_s(v, 'dx').toLowerCase().contains(k)) {
        hit = 'Diagnosis: ${_s(v, 'dx')}';
      } else if (_s(v, 'hospital').toLowerCase().contains(k)) {
        hit = _s(v, 'hospital');
      } else {
        for (final m in _l(v, 'meds')) {
          if (_s(m as Map, 'name').toLowerCase().contains(k)) {
            hit = '${_s(m, 'name')} ${_s(m, 'dose')}'.trim();
            break;
          }
        }
        if (hit == null) {
          for (final t in _l(v, 'tests')) {
            if (_s(t as Map, 'name').toLowerCase().contains(k)) {
              hit = 'Test: ${_s(t, 'name')}';
              break;
            }
          }
        }
      }
      if (hit != null) out.add((i, hit));
    }
    return out;
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
