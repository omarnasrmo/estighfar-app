# كم فاتك من الاستغفار - Build APK Instructions

هذا المشروع Flutter جاهز. لعمل APK (تثبيت على جهاز Android) اتبع الخطوات التالية على جهازك المحلي أو استخدم خدمة CI مثل Codemagic / GitHub Actions.

## متطلبات
- تثبيت Flutter (https://flutter.dev/docs/get-started/install)
- Java JDK وAndroid SDK (Android Studio عادة يُثبتها)
- متصل بجهاز Android أو محاكي

## خطوات سريعة لبناء APK محلياً
1. افتح الطرفية في مجلد المشروع:
   ```
   cd estighfar_project
   ```
2. جلب الحزم:
   ```
   flutter pub get
   ```
3. لتجربة على جهاز متصل:
   ```
   flutter run --release
   ```
4. لبناء APK:
   ```
   flutter build apk --release
   ```
   الناتج يكون في:
   `build/app/outputs/flutter-apk/app-release.apk`

## بدائل (بدون إعداد محلي)
- **Codemagic**: يمكنك ربط GitHub repo وتركه يبني APK أو TestFlight.
- **GitHub Actions**: هناك أكشنات جاهزة لبناء Flutter APK.

## ملاحظة عن الأيقونة
ملف الأيقونة داخل `assets/icon.png`. لتحويله لأيقونات Android/iOS تلقائياً استخدم حزمة `flutter_launcher_icons` أو قم بوضع الأيقونات في المجلدات المناسبة يدوياً.

إذا تريد، أجهز لك GitHub Actions YAML لتبني APK تلقائياً عند رفع المشروع إلى GitHub — أعمله لك فوراً.

