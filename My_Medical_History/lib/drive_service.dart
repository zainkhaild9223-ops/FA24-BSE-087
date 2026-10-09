import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  _AuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _inner.send(request..headers.addAll(_headers));
}

/// Uploads go to the *signed-in user's own* Google Drive.
/// Scope drive.file = the app can only see/manage files it created itself.
class DriveService {
  DriveService._();
  static final instance = DriveService._();

  static const folderName = 'My Medical History';
  final _gs = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
  GoogleSignInAccount? user;
  String? _folderId;

  Future<GoogleSignInAccount?> signIn() async {
    user = await _gs.signInSilently() ?? await _gs.signIn();
    return user;
  }

  Future<void> signOut() async {
    await _gs.signOut();
    user = null;
    _folderId = null;
  }

  Future<drive.DriveApi> _api() async {
    final u = user ?? await signIn();
    if (u == null) throw Exception('Google sign-in required');
    return drive.DriveApi(_AuthClient(await u.authHeaders));
  }

  Future<String> _folder(drive.DriveApi api) async {
    if (_folderId != null) return _folderId!;
    final res = await api.files.list(
      q: "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
      $fields: 'files(id)',
    );
    if (res.files?.isNotEmpty ?? false) return _folderId = res.files!.first.id!;
    final f = await api.files.create(drive.File(name: folderName, mimeType: 'application/vnd.google-apps.folder'));
    return _folderId = f.id!;
  }

  Future<void> ensureFolder() async => _folder(await _api());

  /// Upload a PDF / image to the user's Drive folder.
  Future<drive.File> upload(File file) async {
    final api = await _api();
    final parent = await _folder(api);
    final media = drive.Media(file.openRead(), await file.length());
    return api.files.create(
      drive.File(name: file.path.split(Platform.pathSeparator).last, parents: [parent]),
      uploadMedia: media,
      $fields: 'id,name,webViewLink',
    );
  }

  /// Create or update a JSON backup file in the same folder.
  Future<void> uploadText(String name, String content) async {
    final api = await _api();
    final parent = await _folder(api);
    final bytes = utf8.encode(content);
    final media = drive.Media(Stream.value(bytes), bytes.length, contentType: 'application/json');
    final ex = await api.files.list(q: "name='$name' and '$parent' in parents and trashed=false", $fields: 'files(id)');
    if (ex.files?.isNotEmpty ?? false) {
      await api.files.update(drive.File(), ex.files!.first.id!, uploadMedia: media);
    } else {
      await api.files.create(drive.File(name: name, parents: [parent]), uploadMedia: media);
    }
  }

  Future<bool> trySilent() async {
    try {
      user = await _gs.signInSilently();
    } catch (_) {}
    return user != null;
  }

  /// Read a text file from the user's Drive folder (null if it does not exist).
  Future<String?> downloadText(String name) async {
    final api = await _api();
    final parent = await _folder(api);
    final r = await api.files.list(q: "name='$name' and '$parent' in parents and trashed=false", $fields: 'files(id)');
    if (r.files?.isEmpty ?? true) return null;
    final media = await api.files.get(r.files!.first.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final bytes = <int>[];
    await for (final c in media.stream) {
      bytes.addAll(c);
    }
    return utf8.decode(bytes);
  }
}
