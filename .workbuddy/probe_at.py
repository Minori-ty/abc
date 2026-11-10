"""Sample exact pixel colours from a Figma frame export.

Usage: python probe_at.py <png> x,y x,y ...
Coordinates are frame-design coordinates (412x892). Output is #RRGGBB.
Self-contained: does not import png_probe (which runs work on import).
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


def main():
    path = sys.argv[1]
    w, h, ch, px = load(path)

    def at(x, y):
        i = (y * w + x) * ch
        return '%02X%02X%02X' % tuple(px[i:i + 3])

    left = next(x for x in range(w) if at(x, h // 2) != 'FFFFFF')
    right = next(x for x in range(w - 1, 0, -1) if at(x, h // 2) != 'FFFFFF')
    top = next(y for y in range(h) if at(w // 2, y) != 'FFFFFF')
    bot = next(y for y in range(h - 1, 0, -1) if at(w // 2, y) != 'FFFFFF')
    sx = (right - left + 1) / 412.0
    sy = (bot - top + 1) / 892.0
    print(f'frame=({left},{top}) {right - left + 1}x{bot - top + 1} '
          f'scale={sx:.4f}/{sy:.4f}')
    for arg in sys.argv[2:]:
        dx, dy = (float(v) for v in arg.split(','))
        ix = min(max(int(round(left + dx * sx)), 0), w - 1)
        iy = min(max(int(round(top + dy * sy)), 0), h - 1)
        print(f'  ({dx:g},{dy:g}) -> ({ix},{iy}) #{at(ix, iy)}')


main()
