package com.awxkee.jxlcoder;

import android.graphics.Bitmap;
import android.util.Size;

/**
 * Minimal Java stand-in for jxl-coder's Kotlin "JxlCoder" object (github.com/awxkee/jxl-coder,
 * Apache-2.0 / BSD-3). It keeps the class name and the native method signatures, so the prebuilt
 * libjxlcoder.so from the library's AAR binds to it unchanged, and it needs no Kotlin runtime.
 */
public final class JxlCoder {
    private static final JxlCoder INSTANCE = new JxlCoder();
    private static final boolean LOADED;

    static {
        boolean ok;
        try {
            System.loadLibrary("jxlcoder");
            ok = true;
        } catch (Throwable t) {
            android.util.Log.w("cra.jxl", "JPEG XL library not available", t);
            ok = false;
        }
        LOADED = ok;
    }

    private JxlCoder() {}

    private native Size getSizeImpl(byte[] data);

    private native Bitmap decodeSampledImpl(byte[] data, int width, int height, int colorConfig,
                                            int scaleMode, int resizeFilter);

    public static boolean isJxl(byte[] b, int len) {
        if (len >= 2 && b[0] == (byte) 0xFF && b[1] == (byte) 0x0A) return true;
        byte[] m = {0, 0, 0, 0x0C, 0x4A, 0x58, 0x4C, 0x20, 0x0D, 0x0A, (byte) 0x87, 0x0A};
        if (len < m.length) return false;
        for (int i = 0; i < m.length; i++) if (b[i] != m[i]) return false;
        return true;
    }

    /** {width, height} or null when the data is not a decodable JPEG XL. */
    public static int[] size(byte[] data) {
        if (!LOADED) return null;
        try {
            Size s = INSTANCE.getSizeImpl(data);
            return s == null ? null : new int[] {s.getWidth(), s.getHeight()};
        } catch (Throwable t) {
            android.util.Log.w("cra.jxl", "size failed", t);
            return null;
        }
    }

    /** Decodes to ARGB_8888; sample > 1 shrinks the image by that factor. */
    public static Bitmap decode(byte[] data, int sample) {
        if (!LOADED) return null;
        try {
            if (sample > 1) {
                Size s = INSTANCE.getSizeImpl(data);
                if (s != null) {
                    return INSTANCE.decodeSampledImpl(data, Math.max(1, s.getWidth() / sample),
                        Math.max(1, s.getHeight() / sample), 2, 3, 4);
                }
            }
            return INSTANCE.decodeSampledImpl(data, -1, -1, 2, 1, 6);
        } catch (Throwable t) {
            android.util.Log.w("cra.jxl", "decode failed", t);
            return null;
        }
    }
}
