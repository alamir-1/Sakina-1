# Sakina — تحويل إلى APK أندرويد

## المتطلبات على جهازك
- Node.js (من https://nodejs.org — نسخة LTS)
- Android Studio (من https://developer.android.com/studio)
- JDK 17

---

## الخطوات بالترتيب

### 1. فك الضغط وادخل المجلد
```
cd sakina-app
```

### 2. تثبيت الباكدجات
```
npm install
```

### 3. إضافة منصة أندرويد
```
npx cap add android
```

### 4. مزامنة الملفات
```
npx cap sync android
```

### 4.5 تجهيز الأذان (خطوة مهمة جدًا — لازم قبل البناء)
```
chmod +x scripts/setup-android-azan.sh
./scripts/setup-android-azan.sh
```
السكريبت ده بيحمّل ملفي صوت الأذانين ويحطهم داخل مشروع أندرويد نفسه
(`android/app/src/main/res/raw/azan1.mp3` و `azan2.mp3`)، وبيضيف صلاحيات
الإشعارات والمنبّه الدقيق (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`)
لملف الـ Manifest. من غير الخطوة دي هيرجع الأذان يشتغل بنغمة إشعار عادية
بس مش الأذان الحقيقي، وممكن الإشعارات تتأخر أو ما تظهرش خالص على أندرويد
الحديث. (نفس الخطوة متضافة تلقائيًا في codemagic.yaml لو بتبني عن طريق CI.)

### 5. افتح في Android Studio
```
npx cap open android
```
من Android Studio: Build → Build Bundle(s)/APK(s) → Build APK(s)

### أو مباشرة من Terminal
```
cd android
./gradlew assembleDebug
```

### مكان الـ APK
```
android/app/build/outputs/apk/debug/app-debug.apk
```

---

## ملاحظات خاصة بمشروع Sakina

### ✅ ما يعمل تلقائياً
- Firebase Auth + Realtime Database (كلها HTTPS)
- كل مكتبات Firebase SDK عبر CDN
- خرائط Google (window.open → Google Maps)

### ⚠️ تحتاج انتباه
1. **window.open للخرائط**: عند الضغط على اتجاهات المسجد، سيفتح Google Maps
   في متصفح خارجي — هذا سلوك طبيعي في Capacitor
   (يمكن تحسينه لاحقاً بـ @capacitor/browser plugin)

2. **Firebase Security Rules**: تأكد أن rules مضبوطة
   في Firebase Console → Realtime Database → Rules

3. **الإنترنت مطلوب**: التطبيق يعتمد على Firebase وبيانات أونلاين

4. **نظام الأذان والتذكيرات (بعد التحديث الأخير)**:
   - قبل كل صلاة بـ10 دقايق: إشعار عادي بنغمة الجهاز الافتراضية "اقتربت صلاة كذا".
   - وقت الصلاة نفسه: الأذان الكامل بيشتغل تلقائيًا من نظام أندرويد نفسه
     (مش من كود الصفحة)، حتى لو التطبيق مقفول والموبايل مقفول — طالما
     تم تنفيذ خطوة `setup-android-azan.sh` قبل البناء (خطوة 4.5 فوق).
   - فيه بس صوتين للأذان يقدر المستخدم يختار بينهم من الإعدادات.
   - تذكيرات يومية ثابتة (قابلة للتعديل من الإعدادات): الورد اليومي، حديث
     اليوم، ومتابعة قراءة القرآن — بتتكرر تلقائيًا كل يوم في نفس الميعاد.
   - إشعارات الكميوني والختمة: بتتبعت كإشعار نظام فوري لحظة حدوث الحدث
     نفسه (منشور جديد، إنجاز هدف يومي...)، بس ده محتاج التطبيق يكون شغال
     في الخلفية وقتها (مش مقفول تمامًا) لأنها أحداث لحظية مش معروفة الميعاد
     مقدمًا زي الصلاة.
   - **حدود معروفة**: جدول الصلاة بيتجدد لـ15 يوم قدام في كل مرة يتفتح
     فيها التطبيق. لو الموبايل اتعمله Restart وعدّت أكتر من 15 يوم من غير
     ما يتفتح التطبيق خالص، محتاج المستخدم يفتحه مرة واحدة عشان يجدد
     الجدول. وينصح أيضًا بإيقاف "تحسين البطارية/Battery Optimization" لتطبيق
     Sakina من إعدادات الموبايل عشان أندرويد ميأخرش أو يمنعش المنبّهات.

---

## متغيرات البيئة (ANDROID_HOME)
### Windows:
```
ANDROID_HOME = C:\Users\<YourName>\AppData\Local\Android\Sdk
PATH += %ANDROID_HOME%\platform-tools
```
### Mac/Linux (~/.zshrc):
```
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```
