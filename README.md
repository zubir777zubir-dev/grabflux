# GrabFlux — تطبيق تحميل الفيديوهات

تطبيق أندرويد بتصميم Dark Theme راقٍ لتحميل الفيديوهات من:
- ✅ YouTube
- ✅ TikTok  
- ✅ Instagram

بدون علامة مائية | MP4 أو MP3 | من 360p حتى 4K

---

## خطوات التشغيل والبناء

### 1. تثبيت Flutter (إذا لم يكن مثبتاً)
```
https://docs.flutter.dev/get-started/install/windows
```

### 2. تحقق من الإعداد
```bash
flutter doctor
```

### 3. انتقل إلى مجلد المشروع
```bash
cd grabflux
```

### 4. حمّل المكتبات
```bash
flutter pub get
```

### 5. شغّل على جهازك (تطوير)
```bash
flutter run
```

### 6. ابنِ APK جاهز للتثبيت
```bash
flutter build apk --release
```
ستجد الـ APK في:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## هيكل المشروع

```
grabflux/
├── lib/
│   ├── main.dart              # نقطة الدخول
│   ├── models/
│   │   └── download_model.dart  # نماذج البيانات
│   ├── services/
│   │   └── cobalt_service.dart  # API للتحميل
│   ├── screens/
│   │   └── home_screen.dart    # الشاشة الرئيسية
│   └── widgets/
│       ├── platform_selector.dart
│       ├── format_selector.dart
│       └── quality_selector.dart
└── android/                   # إعدادات أندرويد
```

---

## كيف يعمل؟

التطبيق يستخدم **cobalt.tools API** — وهي خدمة مجانية ومفتوحة المصدر تستخرج روابط التحميل المباشرة من يوتيوب وتيك توك وإنستغرام.

عند الضغط على "تحميل الآن":
1. يُرسل الرابط إلى cobalt.tools API
2. تُعاد رابط التحميل المباشر
3. يفتح التطبيق المتصفح لتحميل الملف مباشرة
