"""Numeric diff between a Flutter golden and the Figma export of the same frame.

Both must be the same size (412 x 892). Reports:
  * share of pixels differing by more than `--tol` (default 12/255)
  * the bounding box of the differing region
  * the 12 rows with the most differing pixels, so a mismatch can be traced to
    the widget that owns that band.

Usage: python diff_png.py <golden.png> <figma.png> [--tol N] [--mask out.png]
"""
import struct
import sys
import zlib


def load(path):
    d = open(path, 'rb').read()
    pos = 8
    idat = b''
    w = h = 0
    ct = 0
    while pos < len(d):
        ln = struct.unpack('>I', d[pos:pos + 4])[0]
        typ = d[pos + 4:pos + 8]
        data = d[pos + 8:pos + 8 + ln]
        pos += 12 + ln
        if typ == b'IHDR':
            w, h, bd, ct = struct.unpack('>IIBB', data[:10])
        elif typ == b'IDAT':
            idat += data
        elif typ == b'IEND':
            break
    raw = zlib.decompress(idat)
    ch = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ct]
    stride = w * ch
    out = bytearray()
    prev = bytearray(stride)
    i = 0
    for _ in range(h):
        f = raw[i]
        i += 1
        line = bytearray(raw[i:i + stride])
        i += stride
        for x in range(stride):
            a = line[x - ch] if x >= ch else 0
            b = prev[x]
            c = prev[x - ch] if x >= ch else 0
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        out += line
        prev = line
    return w, h, ch, bytes(out)


def write_mask(path, w, h, rows):
    """rows: list of bytearray(w*3)."""
    raw = b''.join(b'\x00' + bytes(r) for r in rows)

    def chunk(t, d):
        c = t + d
        return struct.pack('>I', len(d)) + c + struct.pack('>I', zlib.crc32(c) & 0xFFFFFFFF)

    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(raw, 6))
    png += chunk(b'IEND', b'')
    open(path, 'wb').write(png)


def main():
    a_path, b_path = sys.argv[1], sys.argv[2]
    tol = 12
    mask_path = None
    args = sys.argv[3:]
    i = 0
    while i < len(args):
        if args[i] == '--tol':
            tol = int(args[i + 1])
            i += 2
        elif args[i] == '--mask':
            mask_path = args[i + 1]
            i += 2
        else:
            i += 1

    w, h, ch, pa = load(a_path)
    w2, h2, ch2, pb = load(b_path)
    if (w, h) != (w2, h2):
        print(f'size mismatch: {w}x{h} vs {w2}x{h2}')
        return

    total = w * h
    bad = 0
    x0 = y0 = 10 ** 9
    x1 = y1 = -1
    rowhits = [0] * h
    mask_rows = []
    for y in range(h):
        row = bytearray(w * 3)
        for x in range(w):
            ia = (y * w + x) * ch
            ib = (y * w + x) * ch2
            ra, ga, ba = pa[ia], pa[ia + 1], pa[ia + 2]
            rb, gb, bb = pb[ib], pb[ib + 1], pb[ib + 2]
            d = max(abs(ra - rb), abs(ga - gb), abs(ba - bb))
            if d > tol:
                bad += 1
                rowhits[y] += 1
                x0 = min(x0, x)
                x1 = max(x1, x)
                y0 = min(y0, y)
                y1 = max(y1, y)
            row[3 * x] = min(255, d * 4)
            row[3 * x + 1] = min(255, d * 4)
            row[3 * x + 2] = min(255, d * 4)
        mask_rows.append(row)

    print(f'{a_path} vs {b_path}')
    print(f'  tolerance {tol}/255, differing {bad}/{total} = {100.0 * bad / total:.2f}%')
    if bad:
        print(f'  bbox ({x0},{y0})-({x1},{y1})')
        ranked = sorted(range(h), key=lambda y: -rowhits[y])[:12]
        for y in ranked:
            if rowhits[y] == 0:
                continue
            print(f'    y={y:<4} {rowhits[y]:>4} px')
    if mask_path:
        write_mask(mask_path, w, h, mask_rows)
        print(f'  mask -> {mask_path}')


main()
