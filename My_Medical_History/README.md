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
