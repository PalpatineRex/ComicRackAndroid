#!/usr/bin/env bash
# Sign an unsigned APK with a v1 (JAR) signature using the JDK's jarsigner.
#
# Usage: sign.sh UNSIGNED.apk SIGNED.apk KEYSTORE ALIAS
# The keystore password is read from the environment variable KS_PASS.
# NEVER commit the keystore: in CI it comes from GitHub Actions secrets.
set -euo pipefail

if [ "$#" -ne 4 ]; then
  sed -n '2,7p' "$0"
  exit 2
fi
: "${KS_PASS:?KS_PASS must be set}"

unsigned="$1"; signed="$2"; keystore="$3"; alias="$4"

cp "$unsigned" "$signed"
jarsigner -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore "$keystore" -storepass:env KS_PASS "$signed" "$alias"
jarsigner -verify "$signed" | head -3
