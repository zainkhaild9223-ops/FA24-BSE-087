import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';

import '../db/database_helper.dart';
import 'report_service.dart';

class BackupFile {
  final String id;
  final String name;
  final DateTime? created;
  final int size;
  BackupFile(this.id, this.name, this.created, this.size);
}

/// Drive ke My Drive mein "Dairy Farm Backups" folder:
///   - dairy_backup_*.db            (restore ke liye database)
///   - Dairy Farm - Animals         (Google Sheet: tag, name, photo link, status, milk)
///   - Dairy Farm - Milk Records    (Google Sheet: date-wise milk)
///   - Photos/                      (animals ki photos)
/// Scope drive.file: app sirf wohi files dekh sakti hai jo usne khud banayi hon.
class DriveService {
  static const folderName = 'Dairy Farm Backups';
  static const animalsSheetName = 'Dairy Farm - Animals';
  static const milkSheetName = 'Dairy Farm - Milk Records';
  static const _folderMime = 'application/vnd.google-apps.folder';
  static const _sheetMime = 'application/vnd.google-apps.spreadsheet';

  final GoogleSignIn _signIn =
      GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);

  GoogleSignInAccount? get account => _signIn.currentUser;

  Future<GoogleSignInAccount?> signInSilently() => _signIn.signInSilently();
  Future<GoogleSignInAccount?> signIn() => _signIn.signIn();
  Future<void> signOut() => _signIn.signOut();

  Future<drive.DriveApi> _api() async {
    final client = await _signIn.authenticatedClient();
    if (client == null) {
      throw Exception('Google account sign in nahi hai.');
    }
    return drive.DriveApi(client);
  }

  /// Folder dhoondta hai, na mile to bana deta hai.
  Future<String> _folder(drive.DriveApi api, String name, {String? parent}) async {
    final q = StringBuffer(
        "mimeType='$_folderMime' and name='$name' and trashed=false");
    if (parent != null) q.write(" and '$parent' in parents");
    final res = await api.files.list(
      q: q.toString(),
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (res.files != null && res.files!.isNotEmpty) {
      return res.files!.first.id!;
    }
    final folder = await api.files.create(
      drive.File()
        ..name = name
        ..mimeType = _folderMime
        ..parents = parent == null ? null : [parent],
      $fields: 'id',
    );
    return folder.id!;
  }

  /// Same naam ki file ho to update karta hai, warna nayi banata hai.
  /// [convertTo] dene par (jaise Google Sheet) upload ki hui CSV convert ho jati hai.
  /// Drive ka webViewLink wapas deta hai.
  Future<String?> _upsert(
    drive.DriveApi api, {
    required String name,
    required String parent,
    required List<int> bytes,
    required String contentType,
    String? convertTo,
  }) async {
    drive.Media media() =>
        drive.Media(Stream.value(bytes), bytes.length, contentType: contentType);

    final existing = await api.files.list(
      q: "name='$name' and '$parent' in parents and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (existing.files != null && existing.files!.isNotEmpty) {
      final id = existing.files!.first.id!;
      try {
        final f = await api.files
            .update(drive.File(), id, uploadMedia: media(), $fields: 'id,webViewLink');
        return f.webViewLink;
      } catch (_) {
        // update na ho saka to purani file hata kar nayi bana do
        await api.files.delete(id);
      }
    }
    final meta = drive.File()
      ..name = name
      ..parents = [parent];
    if (convertTo != null) meta.mimeType = convertTo;
    final f = await api.files
        .create(meta, uploadMedia: media(), $fields: 'id,webViewLink');
    return f.webViewLink;
  }

  String _safe(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  /// Database file + Google Sheets (animals, milk) + photos Drive par upload.
  Future<void> backup() async {
    final api = await _api();
    final folderId = await _folder(api, folderName);
    final path = await DatabaseHelper.instance.dbPath;

    // File copy karne se pehle DB band karo (data poori tarah file mein likha jaye)
    await DatabaseHelper.instance.close();
    final bytes = await File(path).readAsBytes();

    final name =
        'dairy_backup_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.db';
    final meta = drive.File()
      ..name = name
      ..parents = [folderId];
    final media = drive.Media(Stream.value(bytes), bytes.length);
    await api.files.create(meta, uploadMedia: media);

    // Ab Google Sheets (DB agli query par khud dobara khul jata hai)
    try {
      await _exportSheets(api, folderId);
    } catch (e) {
      throw Exception(
          'Database backup uploaded, but Google Sheet export failed: $e');
    }
  }

  Future<void> _exportSheets(drive.DriveApi api, String folderId) async {
    final photosId = await _folder(api, 'Photos', parent: folderId);

    // 1) Animals ki photos upload karke har ek ka link lo
    final animals = await DatabaseHelper.instance.getAnimals();
    final links = <int, String>{};
    for (final a in animals) {
      if (a.photo == null || a.id == null) continue;
      final link = await _upsert(
        api,
        name: '${_safe(a.tagNo)}.jpg',
        parent: photosId,
        bytes: a.photo!,
        contentType: 'image/jpeg',
      );
      if (link != null) links[a.id!] = link;
    }

    // 2) Animals sheet
    final animalsCsv = await ReportService.animalsCsv(links);
    await _upsert(
      api,
      name: animalsSheetName,
      parent: folderId,
      bytes: utf8.encode(animalsCsv),
      contentType: 'text/csv',
      convertTo: _sheetMime,
    );

    // 3) Milk records sheet
    final milkCsv = await ReportService.milkCsv();
    await _upsert(
      api,
      name: milkSheetName,
      parent: folderId,
      bytes: utf8.encode(milkCsv),
      contentType: 'text/csv',
      convertTo: _sheetMime,
    );
  }

  /// Sirf .db backups ki list (Sheets aur Photos list mein nahi aate).
  Future<List<BackupFile>> listBackups() async {
    final api = await _api();
    final folderId = await _folder(api, folderName);
    final res = await api.files.list(
      q: "'$folderId' in parents and trashed=false and name contains 'dairy_backup_'",
      spaces: 'drive',
      orderBy: 'createdTime desc',
      pageSize: 20,
      $fields: 'files(id,name,createdTime,size)',
    );
    return (res.files ?? [])
        .map((f) => BackupFile(
              f.id!,
              f.name ?? 'backup',
              f.createdTime?.toLocal(),
              int.tryParse(f.size ?? '0') ?? 0,
            ))
        .toList();
  }

  /// Drive se file download karke local dairy.db ko replace karta hai.
  Future<void> restore(String fileId) async {
    final api = await _api();
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    if (bytes.isEmpty) throw Exception('Backup file khali hai.');

    final path = await DatabaseHelper.instance.dbPath;
    await DatabaseHelper.instance.close();
    // Purani journal files hata do taake purana data na mix ho
    for (final ext in ['-wal', '-shm', '-journal']) {
      final f = File('$path$ext');
      if (await f.exists()) await f.delete();
    }
    await File(path).writeAsBytes(bytes, flush: true);
  }

  Future<void> deleteBackup(String fileId) async {
    final api = await _api();
    await api.files.delete(fileId);
  }
}
