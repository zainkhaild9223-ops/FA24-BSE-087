import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';

import '../db/database_helper.dart';

class BackupFile {
  final String id;
  final String name;
  final DateTime? created;
  final int size;
  BackupFile(this.id, this.name, this.created, this.size);
}

/// Backups Drive ke My Drive mein "Dairy Farm Backups" folder mein jate hain.
/// Scope drive.file: app sirf wohi files dekh sakti hai jo usne khud banayi hon,
/// user ki baqi Drive files tak access nahi hoti.
class DriveService {
  static const folderName = 'Dairy Farm Backups';

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

  /// "Dairy Farm Backups" folder dhoondta hai, na mile to bana deta hai.
  Future<String> _folderId(drive.DriveApi api) async {
    final res = await api.files.list(
      q: "mimeType='application/vnd.google-apps.folder' "
          "and name='$folderName' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (res.files != null && res.files!.isNotEmpty) {
      return res.files!.first.id!;
    }
    final folder = await api.files.create(
      drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder',
      $fields: 'id',
    );
    return folder.id!;
  }

  /// Local dairy.db file ko Drive par upload karta hai.
  Future<void> backup() async {
    final api = await _api();
    final folderId = await _folderId(api);
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
  }

  Future<List<BackupFile>> listBackups() async {
    final api = await _api();
    final folderId = await _folderId(api);
    final res = await api.files.list(
      q: "'$folderId' in parents and trashed=false",
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