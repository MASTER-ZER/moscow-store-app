# Moscow Store - Flutter App

متجر شحن الألعاب - تطبيق Flutter (موبايل + Web) مع Supabase.

## المتطلبات

- Flutter SDK 3.2+
- حساب Supabase

## الإعداد

### 1. قاعدة البيانات
نفذ ملف `supabase/schema.sql` في Supabase SQL Editor.

### 2. ضبط الاتصال
تأكد من بيانات الاتصال في `lib/config/supabase_config.dart`.

### 3. تثبيت الحزم
```bash
flutter pub get
```

### 4. تشغيل التطبيق
```bash
# تطبيق موبايل
flutter run

# تطبيق Web (لوحة التحكم)
flutter run -d chrome
```

### 5. تصدير APK
```bash
flutter build apk --release
```

### 6. تصدير iOS
```bash
flutter build ios --release
```

### 7. رفع Web على Vercel
```bash
flutter build web
# ارفع مجلد build/web على Vercel
```

## هيكل المشروع

```
lib/
├── main.dart              # نقطة الدخول
├── app.dart               # الـ Shell الرئيسي
├── config/
│   ├── supabase_config.dart
│   ├── theme.dart
│   └── routes.dart
├── models/                # موديلز البيانات
├── services/              # خدمات Supabase
├── providers/             # Riverpod State Management
├── screens/
│   ├── mobile/            # شاشات التطبيق
│   └── admin/             # لوحة التحكم Web
└── widgets/               # مكونات مشتركة
```

## التقنيات

- Flutter 3.x + Dart
- Supabase (Database + Auth)
- Riverpod (State Management)
- GoRouter (Routing)
- Google Fonts (Cairo)
