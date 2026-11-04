package cra.fork;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.CheckBoxPreference;
import android.preference.PreferenceGroup;
import android.preference.PreferenceManager;

/** Continuous (vertical strip) reading mode: preference and hook from the reader. */
public final class Cont {
    public static final String KEY = "cra_continuous";
    private Cont() {}

    static boolean enabled(Context c) {
        try {
            return PreferenceManager.getDefaultSharedPreferences(c).getBoolean(KEY, false);
        } catch (Throwable t) {
            return false;
        }
    }

    /** Called by the reader once a comic is loaded; true = the strip view replaced the reader's screen. */
    public static boolean open(Activity reader, Object h) {
        try {
            if (h == null || !enabled(reader)) return false;
            new ContReader(reader, h);
            return true;
        } catch (Throwable t) {
            return false;
        }
    }

    /** Adds the "Continuous mode" checkbox to the reader settings screen. */
    public static void addPreference(Context c, PreferenceGroup group) {
        try {
            if (group == null || group.findPreference(KEY) != null) return;
            CheckBoxPreference p = new CheckBoxPreference(c);
            p.setKey(KEY);
            p.setTitle("Continuous mode");
            p.setSummary("Read pages as one vertical strip (webtoon style)");
            p.setDefaultValue(Boolean.FALSE);
            p.setOrder(0);
            group.addPreference(p);
        } catch (Throwable t) {
            // settings stay usable without it
        }
    }

    static SharedPreferences prefs(Context c) {
        return PreferenceManager.getDefaultSharedPreferences(c);
    }
}
