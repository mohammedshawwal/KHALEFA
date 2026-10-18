# تطبيق عطارة خليفة العطار (Flutter)

## التشغيل وبناء APK
1. ثبّت Flutter (3.19 أو أحدث): https://docs.flutter.dev/get-started/install
2. من مجلد فاضي: `flutter create khalifa_attar --org com.khalifa --platforms android`
3. انسخ `pubspec.yaml` و مجلد `lib/` من الملف ده فوق اللي اتعمل (استبدلهم).
4. افتح `android/app/src/main/AndroidManifest.xml` وضيف جوه `<manifest>` قبل `<application>`:
```xml
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="tel"/></intent>
</queries>
```
   وغيّر `android:label` لـ `عطارة خليفة العطار`.
5. `flutter pub get` ثم `flutter run` للتجربة.
6. لبناء APK: `flutter build apk --release` والملف هيطلع في `build/app/outputs/flutter-apk/app-release.apk`.

## تغيير بيانات المحل
كل الأرقام والأسعار في `lib/data.dart`: رقم الواتساب `kWa` والتليفون `kTel` ورقم فودافون كاش `kVcash` ورسوم التوصيل والمنتجات.

## بناء APK من غير كمبيوتر (GitHub)
1. اعمل حساب على github.com وأنشئ مستودع جديد (Repository).
2. ارفع محتويات المجلد ده كلها (pubspec.yaml و lib و .github) على المستودع.
3. ادخل تبويب Actions، هيشتغل "Build APK" لوحده (أو شغّله بزر Run workflow).
4. بعد ما يخلص (حوالي 5-10 دقايق) افتح التشغيل ونزّل الملف `khalifa-attar-apk` من Artifacts، وفك الضغط هتلاقي app-release.apk.
