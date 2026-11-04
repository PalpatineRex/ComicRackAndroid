package cra.fork;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * RAR5 support for the old RAR 1.x-4 reader of the app.
 *
 * {@link #prepare(File)} is called with the file the reader is about to open. A RAR5 archive is
 * converted once into a RAR4 archive with stored (uncompressed) entries in the app's cache
 * directory; the existing reader then opens that copy. Anything else is returned unchanged, and so
 * is the original file if the conversion fails (the reader then reports its usual error).
 */
public final class Rar5Fix {
    private static final String PREFIX = "rar5_";

    private Rar5Fix() {
    }

    public static boolean isRar5(File f) {
        RandomAccessFile raf = null;
        try {
            raf = new RandomAccessFile(f, "r");
            byte[] sig = new byte[8];
            raf.readFully(sig);
            return Rar5Reader.isSignature(sig);
        } catch (IOException e) {
            return false;
        } finally {
            if (raf != null) {
                try {
                    raf.close();
                } catch (IOException ignored) {
                }
            }
        }
    }

    public static synchronized File prepare(File f) {
        try {
            if (f == null || !f.isFile() || !isRar5(f)) {
                return f;
            }
            File dir = new File(System.getProperty("java.io.tmpdir", "/data/local/tmp"));
            String key = Integer.toHexString((f.getAbsolutePath() + "|" + f.length() + "|" + f.lastModified()).hashCode());
            File out = new File(dir, PREFIX + key + ".rar");
            if (out.isFile() && out.length() > 0) {
                return out;
            }
            File[] old = dir.listFiles();
            if (old != null) {
                for (File o : old) {
                    if (o.getName().startsWith(PREFIX)) {
                        o.delete();
                    }
                }
            }
            File tmp = new File(dir, PREFIX + key + ".tmp");
            try {
                Rar5Reader.convert(f, tmp);
            } catch (Throwable t) {
                tmp.delete();
                return f;
            }
            if (!tmp.renameTo(out)) {
                tmp.delete();
                return f;
            }
            return out;
        } catch (Throwable t) {
            return f;
        }
    }
}
