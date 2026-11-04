package cra.fork;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

/** Replaces BitmapFactory.decodeStream in the page readers: same behaviour plus JPEG XL pages. */
public final class Img {
    private Img() {}

    public static Bitmap decode(InputStream in, Rect pad, BitmapFactory.Options o) {
        if (in == null) return BitmapFactory.decodeStream(in, pad, o);
        InputStream s = in.markSupported() ? in : new BufferedInputStream(in, 65536);
        byte[] head = new byte[12];
        int n = 0;
        try {
            s.mark(64);
            while (n < head.length) {
                int r = s.read(head, n, head.length - n);
                if (r < 0) break;
                n += r;
            }
            s.reset();
        } catch (IOException e) {
            return null;
        }
        if (!com.awxkee.jxlcoder.JxlCoder.isJxl(head, n)) {
            return BitmapFactory.decodeStream(s, pad, o);
        }
        try {
            ByteArrayOutputStream bo = new ByteArrayOutputStream(1 << 20);
            byte[] buf = new byte[65536];
            int r;
            while ((r = s.read(buf)) > 0) bo.write(buf, 0, r);
            byte[] data = bo.toByteArray();
            if (o != null && o.inJustDecodeBounds) {
                int[] sz = com.awxkee.jxlcoder.JxlCoder.size(data);
                if (sz != null) {
                    o.outWidth = sz[0];
                    o.outHeight = sz[1];
                    o.outMimeType = "image/jxl";
                }
                return null;
            }
            Bitmap b = com.awxkee.jxlcoder.JxlCoder.decode(data, o == null ? 1 : o.inSampleSize);
            if (b != null && o != null) {
                o.outWidth = b.getWidth();
                o.outHeight = b.getHeight();
                o.outMimeType = "image/jxl";
            }
            return b;
        } catch (IOException e) {
            return null;
        }
    }
}
