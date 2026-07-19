#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# setup-android-azan.sh
#
# Runs AFTER `npx cap add android` (and after `npx cap sync android`), and
# BEFORE the gradle build. It does two things the Capacitor/Android project
# needs for the azan feature to actually work, but that `cap add` never sets
# up on its own:
#
#   1. Downloads the two adhan audio files and bundles them as native Android
#      "raw" resources (android/app/src/main/res/raw/azan1.mp3, azan2.mp3).
#      These filenames MUST match the `rawSound` values in the MUEZZINS array
#      inside www/index.html. The app's JS creates two notification channels
#      at first launch (ensureAzanChannels) whose sound is exactly this file —
#      that is what makes Android play the full azan automatically, even with
#      the app closed and the phone locked, with zero JS involved at the
#      moment the prayer time hits.
#
#   2. Adds the manifest permissions exact-time alarms and notifications need
#      on modern Android (13+ requires POST_NOTIFICATIONS at runtime; 12+
#      requires SCHEDULE_EXACT_ALARM for the prayer-time alarms to fire at
#      the exact minute instead of being silently delayed).
#
# Safe to run more than once (every step checks before it edits/downloads).
# ---------------------------------------------------------------------------
set -euo pipefail

ANDROID_DIR="android"
RES_RAW="$ANDROID_DIR/app/src/main/res/raw"
MANIFEST="$ANDROID_DIR/app/src/main/AndroidManifest.xml"

if [ ! -d "$ANDROID_DIR" ]; then
  echo "❌ android/ directory not found — run 'npx cap add android' first."
  exit 1
fi

mkdir -p "$RES_RAW"

# Must match MUEZZINS[].url / MUEZZINS[].rawSound in www/index.html.
AZAN1_URL="https://cdn.aladhan.com/audio/adhans/a9.mp3"
AZAN2_URL="https://cdn.aladhan.com/audio/adhans/a11-mansour-al-zahrani.mp3"

download_if_missing () {
  local url="$1" dest="$2"
  if [ -s "$dest" ]; then
    echo "✅ $dest already present, skipping download"
  else
    echo "⬇️  Downloading $(basename "$dest") ..."
    curl -L --fail --silent --show-error "$url" -o "$dest"
    echo "✅ Saved $dest"
  fi
}

download_if_missing "$AZAN1_URL" "$RES_RAW/azan1.mp3"
download_if_missing "$AZAN2_URL" "$RES_RAW/azan2.mp3"

# ---- AndroidManifest.xml permissions -------------------------------------
add_permission_if_missing () {
  local perm="$1"
  if grep -q "$perm" "$MANIFEST"; then
    echo "✅ $perm already in manifest"
  else
    echo "➕ Adding $perm to manifest"
    # Insert right before <application ...> — every Capacitor manifest has this tag.
    perl -0pi -e "s#(<application)#<uses-permission android:name=\"$perm\" />\n    \$1#" "$MANIFEST"
  fi
}

add_permission_if_missing "android.permission.POST_NOTIFICATIONS"
add_permission_if_missing "android.permission.SCHEDULE_EXACT_ALARM"
add_permission_if_missing "android.permission.WAKE_LOCK"
add_permission_if_missing "android.permission.RECEIVE_BOOT_COMPLETED"

echo "🎉 Azan native setup complete."
