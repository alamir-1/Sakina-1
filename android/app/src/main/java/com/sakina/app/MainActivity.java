package com.sakina.app;

import android.os.Bundle;
import androidx.core.view.WindowCompat;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Draw edge-to-edge so the WebView receives real system-bar insets
        // and CSS env(safe-area-inset-*) reports the actual height of the
        // phone's gesture bar / nav buttons, instead of always 0.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
    }
}
