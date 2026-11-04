"""Minimal editor for Android binary XML (AXML) files, standard library only.

Supports what this fork needs:
  * replace_strings(data, {old: new})  rewrite entries of the string pool (any length)
  * set_int_attr(data, res_id, value)  change an integer attribute (e.g. versionCode)

Only string pools without styles are handled (true for manifests and res/xml
files in this APK); anything unexpected aborts instead of producing a broken file.
"""
import struct

RES_STRING_POOL_TYPE = 0x0001
RES_XML_TYPE = 0x0003
RES_XML_RESOURCE_MAP_TYPE = 0x0180
RES_XML_START_ELEMENT_TYPE = 0x0102
UTF8_FLAG = 0x100
TYPE_INT_DEC = 0x10
TYPE_INT_HEX = 0x11


def _len8(n: int) -> bytes:
    if n > 0x7FFF:
        raise ValueError("string too long")
    return bytes([n]) if n < 0x80 else bytes([0x80 | (n >> 8), n & 0xFF])


def _len16(n: int) -> bytes:
    if n > 0x7FFFFFFF:
        raise ValueError("string too long")
    if n < 0x8000:
        return struct.pack("<H", n)
    return struct.pack("<HH", 0x8000 | (n >> 16), n & 0xFFFF)


def _read_len8(b: bytes, p: int) -> tuple[int, int]:
    n = b[p]
    if n & 0x80:
        return ((n & 0x7F) << 8) | b[p + 1], p + 2
    return n, p + 1


def _read_len16(b: bytes, p: int) -> tuple[int, int]:
    n = struct.unpack_from("<H", b, p)[0]
    if n & 0x8000:
        return ((n & 0x7FFF) << 16) | struct.unpack_from("<H", b, p + 2)[0], p + 4
    return n, p + 2


def _parse_pool(b: bytes, pos: int):
    (ctype, hsize, size, count, styles, flags, sstart, _ystart) = struct.unpack_from("<HHIIIIII", b, pos)
    if ctype != RES_STRING_POOL_TYPE:
        raise ValueError("first chunk is not a string pool")
    if styles:
        raise ValueError("string pools with styles are not supported")
    utf8 = bool(flags & UTF8_FLAG)
    offsets = struct.unpack_from(f"<{count}I", b, pos + hsize)
    strings = []
    for off in offsets:
        p = pos + sstart + off
        if utf8:
            _, p = _read_len8(b, p)          # utf16 length (ignored)
            n, p = _read_len8(b, p)          # utf8 byte length
            strings.append(b[p:p + n].decode("utf-8"))
        else:
            n, p = _read_len16(b, p)
            strings.append(b[p:p + 2 * n].decode("utf-16-le"))
    return strings, flags, hsize, size


def _build_pool(strings: list[str], flags: int, hsize: int) -> bytes:
    utf8 = bool(flags & UTF8_FLAG)
    data, offsets = bytearray(), []
    for s in strings:
        offsets.append(len(data))
        if utf8:
            raw = s.encode("utf-8")
            data += _len8(len(s.encode("utf-16-le")) // 2) + _len8(len(raw)) + raw + b"\x00"
        else:
            raw = s.encode("utf-16-le")
            data += _len16(len(raw) // 2) + raw + b"\x00\x00"
    while len(data) % 4:
        data += b"\x00"
    sstart = hsize + 4 * len(strings)
    size = sstart + len(data)
    header = struct.pack("<HHIIIIII", RES_STRING_POOL_TYPE, hsize, size, len(strings), 0, flags, sstart, 0)
    header += b"\x00" * (hsize - len(header))
    return header + struct.pack(f"<{len(strings)}I", *offsets) + bytes(data)


def read_strings(data: bytes) -> list[str]:
    _, xml_hsize, _ = struct.unpack_from("<HHI", data, 0)
    return _parse_pool(data, xml_hsize)[0]


def replace_strings(data: bytes, mapping: dict[str, str]) -> bytes:
    xml_type, xml_hsize, _ = struct.unpack_from("<HHI", data, 0)
    if xml_type != RES_XML_TYPE:
        raise ValueError("not a binary XML file")
    strings, flags, hsize, old_size = _parse_pool(data, xml_hsize)
    for old in mapping:
        hits = strings.count(old)
        if hits != 1:
            raise ValueError(f"expected string {old!r} exactly once in the pool, found {hits}")
    strings = [mapping.get(s, s) for s in strings]
    pool = _build_pool(strings, flags, hsize)
    rest = data[xml_hsize + old_size:]
    out = bytearray(data[:xml_hsize]) + pool + rest
    struct.pack_into("<I", out, 4, len(out))
    return bytes(out)


RES_XML_END_ELEMENT_TYPE = 0x0103


def remove_elements(data: bytes, keys: list[str]) -> bytes:
    """Remove every element (with its children) that has an attribute whose raw string
    value is one of `keys` (e.g. a preference's android:key). Each key must match exactly
    one element. Unused strings stay in the pool, which is harmless."""
    strings = read_strings(data)
    wanted = {}
    for k in keys:
        if strings.count(k) != 1:
            raise ValueError(f"key {k!r} not found exactly once in the string pool")
        wanted[strings.index(k)] = k
    _, xml_hsize, _ = struct.unpack_from("<HHI", data, 0)
    chunks, pos = [], xml_hsize
    while pos < len(data):
        ctype, chsize, csize = struct.unpack_from("<HHI", data, pos)
        if csize == 0:
            raise ValueError("corrupt chunk")
        chunks.append((pos, ctype, chsize, csize))
        pos += csize
    drop, found, depth = set(), [], 0
    for i, (pos, ctype, chsize, _csize) in enumerate(chunks):
        if depth:
            drop.add(i)
            if ctype == RES_XML_START_ELEMENT_TYPE:
                depth += 1
            elif ctype == RES_XML_END_ELEMENT_TYPE:
                depth -= 1
            continue
        if ctype == RES_XML_START_ELEMENT_TYPE:
            ext = pos + chsize
            astart, asize, acount = struct.unpack_from("<HHH", data, ext + 8)
            for j in range(acount):
                raw = struct.unpack_from("<I", data, ext + astart + j * asize + 8)[0]
                if raw in wanted:
                    found.append(wanted[raw])
                    drop.add(i)
                    depth = 1
                    break
    if depth:
        raise ValueError("unbalanced elements")
    if sorted(found) != sorted(keys):
        raise ValueError(f"elements found {found}, expected {keys}")
    out = bytearray(data[:xml_hsize])
    for i, (pos, _t, _h, csize) in enumerate(chunks):
        if i not in drop:
            out += data[pos:pos + csize]
    struct.pack_into("<I", out, 4, len(out))
    return bytes(out)


def remove_tag(data: bytes, tag: str) -> bytes:
    """Remove the one element named `tag` (e.g. "CheckBox") with its children."""
    strings = read_strings(data)
    if strings.count(tag) != 1:
        raise ValueError(f"tag {tag!r} not found exactly once in the string pool")
    want = strings.index(tag)
    _, xml_hsize, _ = struct.unpack_from("<HHI", data, 0)
    chunks, pos = [], xml_hsize
    while pos < len(data):
        ctype, chsize, csize = struct.unpack_from("<HHI", data, pos)
        if csize == 0:
            raise ValueError("corrupt chunk")
        chunks.append((pos, ctype, chsize, csize))
        pos += csize
    drop, found, depth = set(), 0, 0
    for i, (pos, ctype, chsize, _csize) in enumerate(chunks):
        if depth:
            drop.add(i)
            if ctype == RES_XML_START_ELEMENT_TYPE:
                depth += 1
            elif ctype == RES_XML_END_ELEMENT_TYPE:
                depth -= 1
            continue
        if ctype == RES_XML_START_ELEMENT_TYPE and struct.unpack_from("<I", data, pos + chsize + 4)[0] == want:
            found += 1
            drop.add(i)
            depth = 1
    if found != 1 or depth:
        raise ValueError(f"expected one <{tag}> element, found {found}")
    out = bytearray(data[:xml_hsize])
    for i, (pos, _t, _h, csize) in enumerate(chunks):
        if i not in drop:
            out += data[pos:pos + csize]
    struct.pack_into("<I", out, 4, len(out))
    return bytes(out)


def set_int_attr(data: bytes, res_id: int, value: int) -> tuple[bytes, int]:
    """Set the single integer attribute whose name has resource id res_id. Returns (data, old)."""
    buf = bytearray(data)
    _, xml_hsize, _ = struct.unpack_from("<HHI", buf, 0)
    pos, res_ids, hits = xml_hsize, [], []
    while pos < len(buf):
        ctype, chsize, csize = struct.unpack_from("<HHI", buf, pos)
        if csize == 0:
            break
        if ctype == RES_XML_RESOURCE_MAP_TYPE:
            n = (csize - chsize) // 4
            res_ids = list(struct.unpack_from(f"<{n}I", buf, pos + chsize))
        elif ctype == RES_XML_START_ELEMENT_TYPE:
            ext = pos + chsize
            astart, asize, acount = struct.unpack_from("<HHH", buf, ext + 8)
            for i in range(acount):
                a = ext + astart + i * asize
                name_idx = struct.unpack_from("<I", buf, a + 4)[0]
                if name_idx < len(res_ids) and res_ids[name_idx] == res_id:
                    if buf[a + 15] not in (TYPE_INT_DEC, TYPE_INT_HEX):
                        raise ValueError(f"attribute 0x{res_id:x} is not an integer")
                    hits.append(a + 16)
        pos += csize
    if len(hits) != 1:
        raise ValueError(f"expected one attribute 0x{res_id:x}, found {len(hits)}")
    old = struct.unpack_from("<I", buf, hits[0])[0]
    struct.pack_into("<I", buf, hits[0], value)
    return bytes(buf), old
