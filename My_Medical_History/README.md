# My Medical History (Flutter)

## Run
1. `flutter create .`  (generates android/ios folders; keep lib/ and pubspec.yaml)
2. `flutter pub get`
3. `flutter run`

## Google Drive setup (files go to the signed-in user's OWN Drive)
1. console.cloud.google.com -> create project -> APIs & Services -> enable **Google Drive API**.
2. OAuth consent screen: add app name + your email; scope `.../auth/drive.file`; add your Google account under **Test users** while in Testing.
3. Credentials -> Create **OAuth client ID**:
   - Android: package name (android/app/build.gradle `applicationId`) + SHA-1 from `cd android && ./gradlew signingReport`
   - iOS: bundle id; put the iOS client ID in Info.plist `GIDClientID` and add the reversed client ID as a URL scheme.
4. iOS Info.plist: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`.
5. Android: set `minSdkVersion 21` or higher.

## Data & Drive backup
- All data is stored locally in one JSON file (`medical_history.json` in the app documents folder).
- Every saved visit is auto-uploaded to the signed-in user's Google Drive folder `My Medical History`.
- After uninstall/reinstall: sign in with the same Google account -> Connect Google Drive -> data is restored automatically.
- Settings -> Sync Now / Restore Backup do it manually.

<img width="754" height="1600" alt="WhatsApp Image 2026-10-11 at 12 03 52 AM" src="https://github.com/user-attachments/assets/c9ea77bf-8bf9-4361-9c52-3c641e767b74" />
<img width="747" height="1600" alt="WhatsApp Image 2026-10-11 at 12 03 52 AM (1)" src="https://github.com/user-attachments/assets/78a85981-f404-4ef6-b855-26b263f144cd" />
<img width="753" height="1600" alt="WhatsApp Image 2026-10-11 at 12 03 53 AM" src="https://github.com/user-attachments/assets/63b83133-a959-4e86-9b1b-665c7670117e" />
<img width="752" height="1600" alt="WhatsApp Image 2026-10-11 at 12 03 53 AM (2)" src="https://github.com/user-attachments/assets/5332f630-5174-428f-8bab-a6dc294e3b41" />
<img width="753" height="1600" alt="WhatsApp Image 2026-10-11 at 12 03 53 AM (3)" src="https://github.com/user-attachments/assets/a1d5f10a-828b-494e-a4f2-387ddea3f499" />
<img width="750" height="1600" alt="WhatsApp Image 2026-10-11 at 12 03 54 AM" src="https://github.com/user-attachments/assets/6c54fdf5-a433-48d2-8797-722de87f452a" />
<img width="753" height="1600" alt="WhatsApp Image 2026-10-11 at 12 03 54 AM (1)" src="https://github.com/user-attachments/assets/a5714014-de77-492f-ab73-6df4e6ebae35" />

