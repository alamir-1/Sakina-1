package com.sakina.app;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.webkit.PermissionRequest;
import androidx.core.content.ContextCompat;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.BridgeWebChromeClient;

/*
 * لماذا هذا التعديل ضروري:
 * الويب فيو (WebView) في أندرويد بيرفض أي طلب getUserMedia() افتراضيًا،
 * حتى لو صلاحية الميكروفون (RECORD_AUDIO) متاحة فعلاً من إعدادات الجهاز/النظام.
 * لازم الكود الأصلي (Native) يعمل override لـ onPermissionRequest ويوافق
 * صراحة على المصدر المطلوب (audio capture)، وإلا هيفضل getUserMedia
 * يرجع NotAllowedError طول الوقت مهما كانت صلاحيات النظام.
 */
public class MainActivity extends BridgeActivity {
  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    bridge.getWebView().setWebChromeClient(new BridgeWebChromeClient(bridge) {
      @Override
      public void onPermissionRequest(final PermissionRequest request) {
        boolean hasMicPermission = ContextCompat.checkSelfPermission(
            MainActivity.this, Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED;

        if (hasMicPermission) {
          // وافق فقط على المصادر اللي بيطلبها الويب فيو نفسه (مثل AUDIO_CAPTURE)
          // بدل ما نوافق على كل حاجة، ده أأمن.
          runOnUiThread(() -> request.grant(request.getResources()));
        } else {
          // صلاحية الميكروفون مش متاحة من النظام أصلًا — ارفض الطلب هنا
          // بدل ما يفضل معلّق، وخلي الـ JS side (getUserMedia catch) يوضح للمستخدم
          // إنه يفتح إعدادات التطبيق ويفعّل الميكروفون.
          runOnUiThread(request::deny);
        }
      }
    });
  }
}
