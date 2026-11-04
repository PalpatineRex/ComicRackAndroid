package cra.test;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.List;
import java.util.zip.CRC32;

/**
 * Opens archives through the app's own RAR reader (com.cyo.common.c.a) the way the library does,
 * and prints every entry with size and CRC32. Run on a device with app_process (see
 * tools/device_test.ps1 notes); never shipped.
 *
 *   CLASSPATH=/data/local/tmp/app.apk:/data/local/tmp/probe.jar \
 *     app_process /system/bin cra.test.Rar5Probe /sdcard/x.cbr
 */
public final class Rar5Probe {
    public static void main(String[] args) throws Exception {
        System.setProperty("java.io.tmpdir", "/data/local/tmp");
        for (String path : args) {
            Class<?> archive = Class.forName("com.cyo.common.c.a");
            Class<?> header = Class.forName("com.cyo.common.c.d.g");
            Constructor<?> ctor = archive.getConstructor(File.class);
            Object a = ctor.newInstance(new File(path));
            Method list = archive.getMethod("c");
            Method extract = archive.getMethod("a", header, java.io.OutputStream.class);
            Field name = header.getField("k");
            Field size = header.getField("m");
            List<?> headers = (List<?>) list.invoke(a);
            System.out.println("ARCHIVE " + path + " entries=" + headers.size());
            for (Object h : headers) {
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                extract.invoke(a, h, out);
                CRC32 crc = new CRC32();
                crc.update(out.toByteArray());
                System.out.println("ENTRY " + name.get(h) + " size=" + size.getLong(h) + " read="
                        + out.size() + " crc=" + Long.toHexString(crc.getValue()));
            }
            archive.getMethod("close").invoke(a);
        }
    }
}
