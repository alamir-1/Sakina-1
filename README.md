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

### 4.6 تفعيل تسجيل الدخول بجوجل (خطوة لازمة عشان زرار "المتابعة عبر جوجل" يشتغل)
زرار جوجل في شاشة تسجيل الدخول جاهز في الكود، لكن محتاج إعداد لمرة واحدة
من طرفك في Firebase Console (مينفعش يتعمل من غير الوصول لحسابك):

1. روح [Firebase Console](https://console.firebase.google.com) → مشروع
   `sakina-76962` → **Authentication → Sign-in method** → فعّل **Google**.
2. من نفس المشروع: **Project settings** (⚙️) → مرّر لتحت لحد **Your apps**
   → التطبيق `com.sakina.app` → زرار **Add fingerprint** → ضيف الـ SHA-1
   بتاع الجهاز اللي هتبني بيه (شوف طريقة استخراجه تحت). لازم تضيف SHA-1
   الخاص بـ debug keystore عشان تجرب، و SHA-1 الخاص بـ release keystore
   لما تنزل نسخة نهائية.
   - لاستخراج SHA-1 بتاع الـ debug keystore (نفس القيمة لكل الأجهزة، افتراضي
     من Android SDK):
     ```
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
     (على ويندوز المسار غالبًا `%USERPROFILE%\.android\debug.keystore`)
3. من نفس صفحة الـ **Your apps** بعد إضافة الـ fingerprint: زرار
   **Download google-services.json** → حط الملف في `android/app/google-services.json`
   بالظبط (جوه مجلد `app`، جنب `build.gradle`). ملفات الـ Gradle في المشروع
   مجهزة تلقائيًا تطبّق Google Services plugin بمجرد وجود الملف ده — مفيش
   حاجة تانية تتغيّر يدويًا.
4. تأكد إن `npm install` اتعمل بعد فك الضغط (هيجيب باكدج
   `@capacitor-firebase/authentication` اللي الزرار بيعتمد عليه)، بعدين
   `npx cap sync android` زي أي خطوة تانية.

من غير الخطوات دي، الزرار هيظهر في الشاشة بس هيقولك رسالة "محتاج إعداد
جوجل الأول" بدل ما يفتح نافذة تسجيل الدخول — التطبيق نفسه مش هيتأثر ولا
هيقف، بس ميزة جوجل بس اللي مش هتشتغل.

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

3. **فتح التطبيق أصبح لا يعتمد على الإنترنت**: بعد آخر تعديل، الشاشة
   الأولى (تسجيل الدخول أو الصفحة الرئيسية لمستخدم مسجّل بالفعل) بتظهر
   فورًا من البيانات المحلية على الجهاز، من غير ما تستنى Firebase خالص —
   حتى لو مفيش نت أصلًا أو النت ضعيف. أي ميزة فعليًا محتاجة إنترنت
   (تسجيل دخول جديد، المزامنة اللحظية بين الأجهزة، المجتمعات...) هتشتغل
   لوحدها أول ما النت يبقى متاح، من غير ما توقف باقي التطبيق.

4. **تسجيل الدخول بجوجل**: الزرار جاهز في الواجهة، لكن محتاج إعداد لمرة
   واحدة في Firebase Console قبل ما يشتغل فعليًا — تفاصيل الخطوات في
   قسم "4.6" فوق.

5. **نظام الأذان والتذكيرات (بعد التحديث الأخير)**:
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
