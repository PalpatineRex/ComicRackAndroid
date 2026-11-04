package cra.fork;

import android.database.Cursor;

/** Translator column of the library database (added in database version 5). */
public final class Tr {
    private Tr() {}

    public static String col(Cursor c) {
        try {
            int i = c.getColumnIndex("Translator");
            return i < 0 ? null : c.getString(i);
        } catch (Throwable t) {
            return null;
        }
    }
}
