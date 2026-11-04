package cra.fork;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.CRC32;

/** Reads a RAR5 archive and writes its files as a RAR4 archive with stored entries. */
final class Rar5Reader {
    private static final int[] SIG = {0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x01, 0x00};

    private static final int NC = 306, NDC = 64, NLDC = 16, NRC = 44, BC = 20;
    private static final int TABLE_BITS = 15;

    static boolean isSignature(byte[] b) {
        if (b.length < 8) {
            return false;
        }
        for (int i = 0; i < 8; i++) {
            if ((b[i] & 0xff) != SIG[i]) {
                return false;
            }
        }
        return true;
    }

    // ---------------------------------------------------------------- archive entries

    private static final class Entry {
        String name;
        long unpackedSize;
        long dataPos;
        long dataSize;
        long crc = -1;
        int method;
        boolean solid;
        long dict;
        boolean dir;
    }

    private final RandomAccessFile in;
    private final RandomAccessFile out;
    private final CRC32 crc = new CRC32();

    private Rar5Reader(RandomAccessFile in, RandomAccessFile out) {
        this.in = in;
        this.out = out;
    }

    static void convert(File src, File dst) throws IOException {
        RandomAccessFile in = new RandomAccessFile(src, "r");
        RandomAccessFile out = null;
        try {
            out = new RandomAccessFile(dst, "rw");
            out.setLength(0);
            new Rar5Reader(in, out).run();
        } finally {
            in.close();
            if (out != null) {
                out.close();
            }
        }
    }

    private long vint(byte[] b, int[] p) throws IOException {
        long v = 0;
        for (int shift = 0; shift < 70; shift += 7) {
            if (p[0] >= b.length) {
                throw new IOException("truncated header");
            }
            int c = b[p[0]++] & 0xff;
            v |= (long) (c & 0x7f) << shift;
            if ((c & 0x80) == 0) {
                return v;
            }
        }
        throw new IOException("bad vint");
    }

    private static long u32(byte[] b, int p) {
        return (b[p] & 0xffL) | (b[p + 1] & 0xffL) << 8 | (b[p + 2] & 0xffL) << 16 | (b[p + 3] & 0xffL) << 24;
    }

    private List<Entry> readEntries() throws IOException {
        List<Entry> list = new ArrayList<Entry>();
        byte[] sig = new byte[8];
        in.seek(0);
        in.readFully(sig);
        if (!isSignature(sig)) {
            throw new IOException("not RAR5");
        }
        long pos = 8;
        long len = in.length();
        while (pos + 7 <= len) {
            in.seek(pos);
            byte[] pre = new byte[4 + 3];
            int got = in.read(pre);
            if (got < 6) {
                break;
            }
            // header size vint starts at pre[4]
            int[] p = {4};
            long hsize;
            try {
                hsize = vint(pre, p);
            } catch (IOException e) {
                // vint longer than the 3 bytes read: read more
                byte[] more = new byte[4 + 10];
                in.seek(pos);
                in.read(more);
                p[0] = 4;
                hsize = vint(more, p);
            }
            long hdrStart = pos + p[0];
            if (hsize <= 0 || hsize > (1 << 20) || hdrStart + hsize > len) {
                throw new IOException("bad header size");
            }
            byte[] h = new byte[(int) hsize];
            in.seek(hdrStart);
            in.readFully(h);
            int[] q = {0};
            long type = vint(h, q);
            long flags = vint(h, q);
            long extraSize = 0, dataSize = 0;
            if ((flags & 1) != 0) {
                extraSize = vint(h, q);
            }
            if ((flags & 2) != 0) {
                dataSize = vint(h, q);
            }
            long dataPos = hdrStart + hsize;
            if (type == 5) {
                break;
            }
            if (type == 4) {
                throw new IOException("encrypted headers");
            }
            if (type == 2) {
                if ((flags & 0x18) != 0) {
                    throw new IOException("multi-volume archives are not supported");
                }
                Entry e = new Entry();
                long fileFlags = vint(h, q);
                e.unpackedSize = vint(h, q);
                vint(h, q); // attributes
                if ((fileFlags & 2) != 0) {
                    q[0] += 4;
                }
                if ((fileFlags & 4) != 0) {
                    e.crc = u32(h, q[0]);
                    q[0] += 4;
                }
                long comp = vint(h, q);
                vint(h, q); // host os
                int nameLen = (int) vint(h, q);
                if (q[0] + nameLen > h.length) {
                    throw new IOException("bad name");
                }
                e.name = new String(h, q[0], nameLen, "UTF-8");
                q[0] += nameLen;
                e.dir = (fileFlags & 1) != 0;
                if ((fileFlags & 8) != 0) {
                    throw new IOException("unknown unpacked size");
                }
                e.method = (int) ((comp >> 7) & 7);
                e.solid = ((comp >> 6) & 1) != 0;
                int version = (int) (comp & 0x3f);
                long dictBase = 131072L << ((comp >> 10) & 15);
                e.dict = dictBase;
                if (version == 1) {
                    e.dict += dictBase / 32 * ((comp >> 15) & 31);
                } else if (version != 0) {
                    throw new IOException("unsupported compression version " + version);
                }
                // extra area: reject encryption (record type 1)
                int ex = h.length - (int) extraSize;
                int[] r = {ex};
                while (r[0] < h.length) {
                    long rsize = vint(h, r);
                    int rend = r[0] + (int) rsize;
                    long rtype = vint(h, r);
                    if (rtype == 1) {
                        throw new IOException("encrypted files are not supported");
                    }
                    r[0] = rend;
                }
                e.dataPos = dataPos;
                e.dataSize = dataSize;
                list.add(e);
            }
            pos = dataPos + dataSize;
        }
        return list;
    }

    private void run() throws IOException {
        List<Entry> entries = readEntries();
        long total = 0, maxDict = 0;
        for (Entry e : entries) {
            if (!e.dir) {
                total += e.unpackedSize;
                if (e.method != 0 && e.dict > maxDict) {
                    maxDict = e.dict;
                }
            }
        }
        out.write(new byte[] {0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x00});
        // main header
        byte[] main = new byte[13];
        main[2] = 0x73;
        main[5] = 13;
        putCrc16(main, 13);
        out.write(main);

        Lz lz = null;
        for (Entry e : entries) {
            if (e.dir) {
                continue;
            }
            if (e.unpackedSize >= 0xFFFFFFFFL || e.dataSize >= 0xFFFFFFFFL) {
                throw new IOException("file too large");
            }
            long hdrPos = out.getFilePointer();
            byte[] name = e.name.getBytes("UTF-8");
            writeFileHeader(hdrPos, name, e.unpackedSize, 0);
            crc.reset();
            if (e.method == 0) {
                copyStored(e);
            } else {
                if (lz == null) {
                    long w = nextPow2(Math.max(65536L, Math.min(maxDict, nextPow2(Math.max(total, 1)))));
                    lz = new Lz((int) Math.min(w, 1L << 30));
                }
                if (!e.solid) {
                    lz.reset();
                }
                lz.decode(e);
            }
            long c = crc.getValue();
            if (e.crc >= 0 && e.crc != c) {
                throw new IOException("CRC error in " + e.name);
            }
            long end = out.getFilePointer();
            out.seek(hdrPos);
            writeFileHeader(hdrPos, name, e.unpackedSize, c);
            out.seek(end);
        }
        out.write(new byte[] {(byte) 0xC4, 0x3D, 0x7B, 0x00, 0x40, 0x07, 0x00});
    }

    private static long nextPow2(long v) {
        long p = 1;
        while (p < v && p < (1L << 40)) {
            p <<= 1;
        }
        return p;
    }

    private void putCrc16(byte[] b, int len) {
        CRC32 c = new CRC32();
        c.update(b, 2, len - 2);
        int v = (int) (c.getValue() & 0xffff);
        b[0] = (byte) v;
        b[1] = (byte) (v >> 8);
    }

    private static void put32(byte[] b, int p, long v) {
        b[p] = (byte) v;
        b[p + 1] = (byte) (v >> 8);
        b[p + 2] = (byte) (v >> 16);
        b[p + 3] = (byte) (v >> 24);
    }

    private void writeFileHeader(long pos, byte[] name, long size, long fileCrc) throws IOException {
        int hs = 32 + name.length;
        byte[] h = new byte[hs];
        h[2] = 0x74;
        h[3] = 0x00;
        h[4] = (byte) 0x80;
        h[5] = (byte) hs;
        h[6] = (byte) (hs >> 8);
        put32(h, 7, size);
        put32(h, 11, size);
        h[15] = 3; // host OS: unix
        put32(h, 16, fileCrc);
        put32(h, 20, 0x00210000L);
        h[24] = 29;
        h[25] = 0x30;
        h[26] = (byte) name.length;
        h[27] = (byte) (name.length >> 8);
        put32(h, 28, 0x81A4L);
        System.arraycopy(name, 0, h, 32, name.length);
        putCrc16(h, hs);
        out.seek(pos);
        out.write(h);
    }

    private void copyStored(Entry e) throws IOException {
        if (e.dataSize != e.unpackedSize) {
            throw new IOException("stored size mismatch");
        }
        in.seek(e.dataPos);
        byte[] buf = new byte[1 << 16];
        long left = e.dataSize;
        while (left > 0) {
            int n = in.read(buf, 0, (int) Math.min(buf.length, left));
            if (n <= 0) {
                throw new IOException("truncated data");
            }
            crc.update(buf, 0, n);
            out.write(buf, 0, n);
            left -= n;
        }
    }

    // ---------------------------------------------------------------- LZ decoder

    private static final class Filter {
        long start;
        long length;
        int type;
        int channels;
    }

    private final class Lz {
        byte[] win;
        int mask;
        long total; // bytes produced since the window was created
        long flushed;
        long fileBase;
        long fileEnd;
        int[] reps = new int[4];
        int lastLen;
        int[] tMain, tDist, tLow, tRep;
        final List<Filter> filters = new ArrayList<Filter>();
        byte[] obuf = new byte[1 << 16];

        // bit reader
        byte[] ibuf = new byte[1 << 16];
        int ipos, ilen;
        long bytesRead; // bytes consumed from the region into acc
        long regionEnd;
        long acc;
        int nbits;
        long fileInPos;

        Lz(int size) {
            win = new byte[size];
            mask = size - 1;
        }

        void reset() {
            java.util.Arrays.fill(reps, 0);
            lastLen = 0;
            tMain = tDist = tLow = tRep = null;
        }

        // ---- bits
        private void fill() throws IOException {
            while (nbits <= 32) {
                int b;
                if (bytesRead >= regionEnd) {
                    b = 0;
                } else {
                    if (ipos >= ilen) {
                        in.seek(fileInPos);
                        int want = (int) Math.min(ibuf.length, regionEnd - bytesRead);
                        ilen = in.read(ibuf, 0, want);
                        if (ilen <= 0) {
                            throw new IOException("truncated data");
                        }
                        fileInPos += ilen;
                        ipos = 0;
                    }
                    b = ibuf[ipos++] & 0xff;
                }
                bytesRead++;
                acc = (acc << 8) | b;
                nbits += 8;
            }
        }

        int peek(int n) throws IOException {
            if (nbits < n) {
                fill();
            }
            return (int) ((acc >>> (nbits - n)) & ((1L << n) - 1));
        }

        void skip(int n) {
            nbits -= n;
        }

        long bits(int n) throws IOException {
            if (n == 0) {
                return 0;
            }
            if (n <= 25) {
                int v = peek(n);
                skip(n);
                return v;
            }
            long hi = bits(n - 16);
            return (hi << 16) | bits(16);
        }

        long bitPos() {
            return bytesRead * 8 - nbits;
        }

        void align() {
            nbits -= nbits & 7;
        }

        // ---- tables
        private int[] build(int[] lens, int off, int n) throws IOException {
            int[] count = new int[16];
            for (int i = 0; i < n; i++) {
                count[lens[off + i]]++;
            }
            count[0] = 0;
            int[] next = new int[17];
            for (int l = 1; l <= 15; l++) {
                next[l + 1] = (next[l] + count[l]) << 1;
            }
            int[] tab = new int[1 << TABLE_BITS];
            for (int s = 0; s < n; s++) {
                int l = lens[off + s];
                if (l == 0) {
                    continue;
                }
                int c = next[l]++;
                int start = c << (TABLE_BITS - l);
                int cnt = 1 << (TABLE_BITS - l);
                if (start + cnt > tab.length) {
                    throw new IOException("bad huffman table");
                }
                int val = (l << 16) | s;
                for (int i = 0; i < cnt; i++) {
                    tab[start + i] = val;
                }
            }
            return tab;
        }

        private int sym(int[] tab) throws IOException {
            int e = tab[peek(TABLE_BITS)];
            if (e == 0) {
                throw new IOException("bad huffman code");
            }
            skip(e >>> 16);
            return e & 0xffff;
        }

        private void readTables() throws IOException {
            int[] bl = new int[BC];
            for (int i = 0; i < BC; ) {
                int v = (int) bits(4);
                if (v == 15) {
                    int n = (int) bits(4);
                    if (n == 0) {
                        bl[i++] = 15;
                    } else {
                        n += 2;
                        while (n-- > 0 && i < BC) {
                            bl[i++] = 0;
                        }
                    }
                } else {
                    bl[i++] = v;
                }
            }
            int[] blTab = build(bl, 0, BC);
            int total = NC + NDC + NLDC + NRC;
            int[] lens = new int[total];
            for (int i = 0; i < total; ) {
                int s = sym(blTab);
                if (s < 16) {
                    lens[i++] = s;
                } else {
                    int n, v;
                    if (s < 18) {
                        if (i == 0) {
                            throw new IOException("bad table");
                        }
                        n = s == 16 ? 3 + (int) bits(3) : 11 + (int) bits(7);
                        v = lens[i - 1];
                    } else {
                        n = s == 18 ? 3 + (int) bits(3) : 11 + (int) bits(7);
                        v = 0;
                    }
                    while (n-- > 0 && i < total) {
                        lens[i++] = v;
                    }
                }
            }
            tMain = build(lens, 0, NC);
            tDist = build(lens, NC, NDC);
            tLow = build(lens, NC + NDC, NLDC);
            tRep = build(lens, NC + NDC + NLDC, NRC);
        }

        // ---- output
        private void put(int b) {
            win[(int) (total & mask)] = (byte) b;
            total++;
        }

        private void copy(int len, int dist) throws IOException {
            if (dist <= 0 || dist > win.length || dist > total) {
                throw new IOException("bad distance");
            }
            long left = fileEnd - total;
            if (len > left) {
                len = (int) left;
            }
            int src = (int) ((total - dist) & mask);
            int dst = (int) (total & mask);
            for (int i = 0; i < len; i++) {
                win[dst] = win[src];
                dst = (dst + 1) & mask;
                src = (src + 1) & mask;
            }
            total += len;
        }

        private void write(long from, long to) throws IOException {
            while (from < to) {
                int n = (int) Math.min(obuf.length, to - from);
                int p = (int) (from & mask);
                int first = Math.min(n, win.length - p);
                System.arraycopy(win, p, obuf, 0, first);
                if (first < n) {
                    System.arraycopy(win, 0, obuf, first, n - first);
                }
                crc.update(obuf, 0, n);
                out.write(obuf, 0, n);
                from += n;
            }
        }

        private void process() throws IOException {
            while (flushed < total) {
                Filter f = filters.isEmpty() ? null : filters.get(0);
                if (f == null) {
                    write(flushed, total);
                    flushed = total;
                    return;
                }
                if (f.start > flushed) {
                    long to = Math.min(total, f.start);
                    write(flushed, to);
                    flushed = to;
                    if (flushed < f.start) {
                        return;
                    }
                }
                if (f.start < flushed) {
                    throw new IOException("bad filter position");
                }
                if (total - f.start < f.length) {
                    return;
                }
                if (f.length > (1 << 26)) {
                    throw new IOException("filter too large");
                }
                byte[] data = new byte[(int) f.length];
                int p = (int) (f.start & mask);
                int first = (int) Math.min(data.length, win.length - p);
                System.arraycopy(win, p, data, 0, first);
                if (first < data.length) {
                    System.arraycopy(win, 0, data, first, data.length - first);
                }
                byte[] res = applyFilter(f, data, f.start - fileBase);
                crc.update(res, 0, res.length);
                out.write(res, 0, res.length);
                flushed = f.start + f.length;
                filters.remove(0);
            }
        }

        private byte[] applyFilter(Filter f, byte[] d, long fileOffset) throws IOException {
            int len = d.length;
            switch (f.type) {
                case 0: { // delta
                    byte[] r = new byte[len];
                    int ch = f.channels;
                    int idx = 0;
                    for (int i = 0; i < ch; i++) {
                        int prev = 0;
                        for (int j = i; j < len; j += ch) {
                            prev = (prev - d[idx++]) & 0xff;
                            r[j] = (byte) prev;
                        }
                    }
                    return r;
                }
                case 1:
                case 2: { // E8, E8E9
                    boolean e9 = f.type == 2;
                    final long fileSize = 0x1000000L;
                    for (int i = 0; i + 4 < len; ) {
                        int b = d[i++] & 0xff;
                        if (b == 0xE8 || (e9 && b == 0xE9)) {
                            long offset = (i + fileOffset) % fileSize;
                            long addr = u32(d, i);
                            if ((addr & 0x80000000L) != 0) {
                                if (((addr + offset) & 0x80000000L) == 0) {
                                    put32(d, i, addr + fileSize);
                                }
                            } else if (((addr - fileSize) & 0x80000000L) != 0) {
                                put32(d, i, addr - offset);
                            }
                            i += 4;
                        }
                    }
                    return d;
                }
                case 3: { // ARM
                    for (int i = 0; i + 3 < len; i += 4) {
                        if ((d[i + 3] & 0xff) == 0xEB) {
                            long off = (d[i] & 0xffL) | (d[i + 1] & 0xffL) << 8 | (d[i + 2] & 0xffL) << 16;
                            off -= (fileOffset + i) / 4;
                            d[i] = (byte) off;
                            d[i + 1] = (byte) (off >> 8);
                            d[i + 2] = (byte) (off >> 16);
                        }
                    }
                    return d;
                }
                default:
                    throw new IOException("unknown filter");
            }
        }

        private long filterData() throws IOException {
            int n = (int) bits(2) + 1;
            long v = 0;
            for (int i = 0; i < n; i++) {
                v |= bits(8) << (8 * i);
            }
            return v;
        }

        private int lenFromSlot(int slot) throws IOException {
            if (slot < 8) {
                return slot + 2;
            }
            int lb = (slot >> 2) - 1;
            return 2 + ((4 | (slot & 3)) << lb) + (int) bits(lb);
        }

        private int readDist() throws IOException {
            int ds = sym(tDist);
            if (ds < 4) {
                return ds + 1;
            }
            int db = (ds >> 1) - 1;
            long dist = 1 + ((long) (2 | (ds & 1)) << db);
            if (db >= 4) {
                if (db > 4) {
                    dist += bits(db - 4) << 4;
                }
                dist += sym(tLow);
            } else {
                dist += bits(db);
            }
            if (dist > Integer.MAX_VALUE) {
                throw new IOException("bad distance");
            }
            return (int) dist;
        }

        void decode(Entry e) throws IOException {
            fileBase = total;
            fileEnd = total + e.unpackedSize;
            flushed = total;
            filters.clear();
            regionEnd = e.dataSize;
            bytesRead = 0;
            acc = 0;
            nbits = 0;
            ipos = ilen = 0;
            fileInPos = e.dataPos;
            long blockEnd = 0;
            boolean lastBlock = false;
            boolean haveBlock = false;
            while (total < fileEnd) {
                if (!haveBlock || bitPos() >= blockEnd) {
                    if (haveBlock && lastBlock) {
                        throw new IOException("data ended early");
                    }
                    align();
                    int flags = (int) bits(8);
                    int chk = (int) bits(8);
                    int sizeBytes = ((flags >> 3) & 7) + 1;
                    long size = 0;
                    int sum = 0x5A ^ flags;
                    for (int i = 0; i < sizeBytes; i++) {
                        int b = (int) bits(8);
                        sum ^= b;
                        size |= (long) b << (8 * i);
                    }
                    if ((sum & 0xff) != chk) {
                        throw new IOException("bad block header");
                    }
                    lastBlock = (flags & 0x40) != 0;
                    long start = bitPos();
                    blockEnd = start + (size - 1) * 8 + (flags & 7) + 1;
                    haveBlock = true;
                    if ((flags & 0x80) != 0) {
                        readTables();
                    } else if (tMain == null) {
                        throw new IOException("missing tables");
                    }
                    continue;
                }
                int s = sym(tMain);
                if (s < 256) {
                    put(s);
                } else if (s == 256) {
                    Filter f = new Filter();
                    f.start = total + filterData();
                    f.length = filterData();
                    f.type = (int) bits(3);
                    if (f.type == 0) {
                        f.channels = (int) bits(5) + 1;
                    }
                    filters.add(f);
                } else if (s == 257) {
                    if (lastLen > 0) {
                        copy(lastLen, reps[0]);
                    }
                } else if (s < 262) {
                    int idx = s - 258;
                    int dist = reps[idx];
                    for (int j = idx; j > 0; j--) {
                        reps[j] = reps[j - 1];
                    }
                    reps[0] = dist;
                    int len = lenFromSlot(sym(tRep));
                    lastLen = len;
                    copy(len, dist);
                } else {
                    int len = lenFromSlot(s - 262);
                    int dist = readDist();
                    if (dist > 0x100) {
                        len++;
                        if (dist > 0x2000) {
                            len++;
                            if (dist > 0x40000) {
                                len++;
                            }
                        }
                    }
                    reps[3] = reps[2];
                    reps[2] = reps[1];
                    reps[1] = reps[0];
                    reps[0] = dist;
                    lastLen = len;
                    copy(len, dist);
                }
                if (total - flushed >= 0x10000) {
                    process();
                }
            }
            process();
            if (flushed != fileEnd) {
                // pending filter that never completed
                write(flushed, fileEnd);
                flushed = fileEnd;
            }
        }
    }
}
