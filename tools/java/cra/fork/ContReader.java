package cra.fork;

import android.app.Activity;
import android.app.Application;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.DisplayMetrics;
import android.util.LruCache;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Vertical strip reader drawn inside the (already declared) reader activity. Talks to the original
 * app's comic source (obfuscated interface com.cyo.comicrack.a.b.h) by reflection: a() = ComicInfo,
 * a(int page, int size) = page bitmap (c(int) is only a small thumbnail). ComicInfo: e() = page count, field g = current page, b(int) = set current
 * page, g() = furthest page read, c(int) = set furthest page.
 */
final class ContReader implements Application.ActivityLifecycleCallbacks {
    private final Activity host;
    private final Object src;
    private final Object info;
    private final Method pageBitmap;
    private final int pages;
    private final ListView list;
    private TextView label;
    private final int rowMin;
    private final int size;
    private int shown = -1;
    private int pendingSel = -1;
    private final Handler ui = new Handler(Looper.getMainLooper());
    private final ExecutorService io = Executors.newSingleThreadExecutor();
    private final Set<Integer> loading = new HashSet<Integer>();
    private final LruCache<Integer, Bitmap> cache;
    private volatile boolean dead;

    ContReader(Activity host, Object src) throws Exception {
        this.host = host;
        this.src = src;
        Class<?> hi = Class.forName("com.cyo.comicrack.a.b.h");
        info = hi.getMethod("a").invoke(src);
        pageBitmap = hi.getMethod("a", int.class, int.class);
        pages = ((Integer) info.getClass().getMethod("e").invoke(info)).intValue();
        if (pages <= 0) throw new IllegalStateException("no pages");
        DisplayMetrics dm = host.getResources().getDisplayMetrics();
        rowMin = dm.widthPixels * 3 / 2;
        size = Math.max(1024, dm.widthPixels * 2);
        int budget = (int) Math.max(8L << 20, Runtime.getRuntime().maxMemory() / 5);
        cache = new LruCache<Integer, Bitmap>(budget) {
            @Override
            protected int sizeOf(Integer k, Bitmap v) {
                return v.getByteCount();
            }
        };
        int start = 0;
        try {
            Field g = info.getClass().getField("g");
            start = Math.max(0, Math.min(pages - 1, g.getInt(info)));
        } catch (Throwable t) {
            // start at the first page
        }
        final Activity act = host;
        list = new ListView(host) {
            @Override
            public boolean dispatchKeyEvent(KeyEvent e) {
                if (e.getKeyCode() == KeyEvent.KEYCODE_BACK) {
                    if (e.getAction() == KeyEvent.ACTION_UP) act.finish();
                    return true;
                }
                int kc = e.getKeyCode();
                if (kc == KeyEvent.KEYCODE_VOLUME_DOWN || kc == KeyEvent.KEYCODE_VOLUME_UP) {
                    if (e.getAction() == KeyEvent.ACTION_DOWN) page(kc == KeyEvent.KEYCODE_VOLUME_DOWN ? 1 : -1);
                    return true;
                }
                return super.dispatchKeyEvent(e);
            }
        };
        list.setDivider(null);
        list.setCacheColorHint(Color.BLACK);
        // blank footer: lets the last page scroll up to the top (and a saved position be restored)
        View footer = new View(host);
        footer.setLayoutParams(new AbsListView.LayoutParams(-1, dm.heightPixels));
        list.addFooterView(footer, null, false);
        list.setAdapter(new Pages());
        list.setOnScrollListener(new AbsListView.OnScrollListener() {
            public void onScrollStateChanged(AbsListView v, int s) {}

            public void onScroll(AbsListView v, int first, int visible, int total) {
                View top = v.getChildAt(0);
                // the page that fills most of the screen counts as the current one
                if (top != null && top.getBottom() < v.getHeight() / 2 && first + 1 < total) first++;
                if (first > pages - 1) first = pages - 1; // the footer is not a page
                show(first);
            }
        });
        FrameLayout root = new Zoom(host);
        root.setBackgroundColor(Color.BLACK);
        root.addView(list, new FrameLayout.LayoutParams(-1, -1));
        label = new TextView(host);
        label.setTextColor(Color.WHITE);
        label.setBackgroundColor(0x99000000);
        label.setPadding(18, 6, 18, 6);
        root.addView(label, new FrameLayout.LayoutParams(-2, -2, Gravity.BOTTOM | Gravity.RIGHT));
        host.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        host.setContentView(root);
        list.requestFocus();
        try {
            Class.forName("com.cyo.comicrack.a.f").getMethod("b", hi).invoke(null, src);
        } catch (Throwable t) {
            // reading history is optional
        }
        android.util.Log.i("cra.cont", "open: " + pages + " pages, start at " + start);
        pendingSel = start;
        list.setSelectionFromTop(start, 0);
        show(start);
        host.getApplication().registerActivityLifecycleCallbacks(this);
    }

    private void show(int first) {
        if (label == null || first == shown || pages == 0) return;
        shown = first;
        label.setText((first + 1) + " / " + pages);
    }

    private void save() {
        try {
            int p = Math.max(0, Math.min(pages - 1, shown));
            android.util.Log.i("cra.cont", "save: page " + p);
            Class<?> ic = info.getClass();
            ic.getMethod("b", int.class).invoke(info, p);
            int far = ((Integer) ic.getMethod("g").invoke(info)).intValue();
            if (p > far) ic.getMethod("c", int.class).invoke(info, p);
            Class<?> hi = Class.forName("com.cyo.comicrack.a.b.h");
            Class.forName("com.cyo.comicrack.a.f").getMethod("a", hi).invoke(null, src);
        } catch (Throwable t) {
            // progress is best effort
        }
    }

    public void onActivityPaused(Activity a) {
        if (a == host) save();
    }

    public void onActivityDestroyed(Activity a) {
        if (a != host) return;
        dead = true;
        io.shutdownNow();
        host.getApplication().unregisterActivityLifecycleCallbacks(this);
    }

    public void onActivityCreated(Activity a, Bundle b) {}

    public void onActivityStarted(Activity a) {}

    public void onActivityResumed(Activity a) {}

    public void onActivityStopped(Activity a) {}

    public void onActivitySaveInstanceState(Activity a, Bundle b) {}

    private void load(final int i) {
        synchronized (loading) {
            if (!loading.add(i)) return;
        }
        io.execute(new Runnable() {
            public void run() {
                Bitmap bm = null;
                try {
                    bm = (Bitmap) pageBitmap.invoke(src, i, size);
                } catch (Throwable t) {
                    // page stays blank
                }
                final Bitmap res = bm;
                synchronized (loading) {
                    loading.remove(i);
                }
                if (res != null) cache.put(i, res);
                ui.post(new Runnable() {
                    public void run() {
                        if (dead || res == null) return;
                        list.invalidateViews();
                        if (pendingSel >= 0 && i >= pendingSel) {
                            // first layout used placeholder heights: put the saved page back on top once
                            list.setSelectionFromTop(pendingSel, 0);
                            pendingSel = -1;
                        }
                    }
                });
            }
        });
    }

    private void page(int dir) {
        list.smoothScrollBy(dir * list.getHeight() * 8 / 10, 250);
    }

    /** Pinch / double-tap zoom of the whole strip, drag to pan when zoomed, tap top/bottom to page. */
    private final class Zoom extends FrameLayout {
        private float scale = 1f;
        private float tx;
        private boolean scaling;
        private final ScaleGestureDetector pinch;
        private final GestureDetector taps;

        Zoom(Activity a) {
            super(a);
            pinch = new ScaleGestureDetector(a, new ScaleGestureDetector.SimpleOnScaleGestureListener() {
                @Override
                public boolean onScale(ScaleGestureDetector d) {
                    apply(scale * d.getScaleFactor());
                    return true;
                }
            });
            taps = new GestureDetector(a, new GestureDetector.SimpleOnGestureListener() {
                @Override
                public boolean onDoubleTap(MotionEvent e) {
                    apply(scale > 1.05f ? 1f : 2f);
                    return true;
                }

                @Override
                public boolean onSingleTapConfirmed(MotionEvent e) {
                    float y = e.getY() / Math.max(1, getHeight());
                    if (y < 0.3f) page(-1);
                    else if (y > 0.7f) page(1);
                    return true;
                }

                @Override
                public boolean onScroll(MotionEvent a1, MotionEvent a2, float dx, float dy) {
                    if (scale > 1f && !scaling) {
                        tx -= dx;
                        apply(scale);
                    }
                    return false;
                }
            });
        }

        void apply(float s) {
            scale = Math.max(1f, Math.min(4f, s));
            float limit = getWidth() * (scale - 1f) / 2f;
            tx = scale <= 1f ? 0f : Math.max(-limit, Math.min(limit, tx));
            list.setPivotX(getWidth() / 2f);
            list.setPivotY(getHeight() / 2f);
            list.setScaleX(scale);
            list.setScaleY(scale);
            list.setTranslationX(tx);
        }

        @Override
        public boolean dispatchTouchEvent(MotionEvent e) {
            pinch.onTouchEvent(e);
            scaling = pinch.isInProgress();
            taps.onTouchEvent(e);
            if (scaling) {
                if (e.getActionMasked() == MotionEvent.ACTION_POINTER_DOWN) {
                    MotionEvent c = MotionEvent.obtain(e);
                    c.setAction(MotionEvent.ACTION_CANCEL);
                    super.dispatchTouchEvent(c);
                    c.recycle();
                }
                return true;
            }
            return super.dispatchTouchEvent(e);
        }
    }

    private class Pages extends BaseAdapter {
        public int getCount() {
            return pages;
        }

        public Object getItem(int i) {
            return null;
        }

        public long getItemId(int i) {
            return i;
        }

        public View getView(int i, View v, ViewGroup parent) {
            ImageView iv = v instanceof ImageView ? (ImageView) v : new ImageView(host);
            iv.setAdjustViewBounds(true);
            iv.setScaleType(ImageView.ScaleType.FIT_CENTER);
            iv.setLayoutParams(new AbsListView.LayoutParams(-1, -2));
            Bitmap bm = cache.get(i);
            if (bm != null) {
                iv.setMinimumHeight(0);
                iv.setImageBitmap(bm);
            } else {
                iv.setImageBitmap(null);
                iv.setMinimumHeight(rowMin);
                load(i);
            }
            if (i + 1 < pages && cache.get(i + 1) == null) load(i + 1);
            return iv;
        }
    }
}
