"""Crop + magnify a region of a Figma frame export, so text and small glyphs
become readable in the terminal/viewer.

Usage:
  python crop.py <png> x,y,w,h [zoom] [out.png]

Coordinates are frame-design coordinates (412x892); the script locates the
frame inside the export (same logic as probe_at.py) and maps them to pixels.
Output defaults to .workbuddy/crop.png and is upscaled with nearest-neighbour
so no resampling blurs the pixel grid.
"""
import struct
import sys
import zlib


def load(path):
    """Minimal PNG decoder -> (width, height, channels, pixels)."""
    d = open(path, 'rb').read()
    pos, idat, w, h, ct = 8, b'', 0, 0, 0
    while pos < len(d):
        ln = struct.unpack('>I', d[pos:pos + 4])[0]
        typ = d[pos + 4:pos + 8]
        data = d[pos + 8:pos + 8 + ln]
        pos += 12 + ln
        if typ == b'IHDR':
            w, h, _bd, ct = struct.unpack('>IIBB', data[:10])
        elif typ == b'IDAT':
            idat += data
        elif typ == b'IEND':
            break
    raw = zlib.decompress(idat)
    nc = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ct]
    stride = w * nc
    out = bytearray()
    prev = bytearray(stride)
    i = 0
    for _ in range(h):
        f = raw[i]
        i += 1
        line = bytearray(raw[i:i + stride])
        i += stride
        for x in range(stride):
            a = line[x - nc] if x >= nc else 0
            b = prev[x]
            c = prev[x - nc] if x >= nc else 0
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
    return w, h, nc, bytes(out)


def encode(path, w, h, rows):
    def chunk(tag, data):
        return (struct.pack('>I', len(data)) + tag + data +
                struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF))

    raw = b''.join(b'\x00' + r for r in rows)
    png = (b'\x89PNG\r\n\x1a\n'
           + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
           + chunk(b'IDAT', zlib.compress(raw, 6))
           + chunk(b'IEND', b''))
    open(path, 'wb').write(png)


def main():
    src = sys.argv[1]
    x, y, cw, chh = (float(v) for v in sys.argv[2].split(','))
    zoom = int(sys.argv[3]) if len(sys.argv) > 3 else 4
    out = sys.argv[4] if len(sys.argv) > 4 else '.workbuddy/crop.png'

    w, h, nch, px = load(src)

    def at(ix, iy):
        i = (iy * w + ix) * nch
        return bytes(px[i:i + 3])

    left = next(ix for ix in range(w) if at(ix, h // 2) != b'\xff\xff\xff')
    right = next(ix for ix in range(w - 1, 0, -1) if at(ix, h // 2) != b'\xff\xff\xff')
    top = next(iy for iy in range(h) if at(w // 2, iy) != b'\xff\xff\xff')
    bot = next(iy for iy in range(h - 1, 0, -1) if at(w // 2, iy) != b'\xff\xff\xff')
    sx = (right - left + 1) / 412.0
    sy = (bot - top + 1) / 892.0

    x0 = int(round(left + x * sx))
    y0 = int(round(top + y * sy))
    x1 = int(round(left + (x + cw) * sx))
    y1 = int(round(top + (y + chh) * sy))

    rows = []
    for iy in range(y0, y1):
        row = b''.join(at(min(max(ix, 0), w - 1), min(max(iy, 0), h - 1)) * zoom
                       for ix in range(x0, x1) for _ in range(zoom))
        rows.extend([row] * zoom)
    encode(out, (x1 - x0) * zoom, (y1 - y0) * zoom, rows)
    print(f'{out}  src=({x0},{y0})-({x1},{y1}) zoom={zoom} '
          f'-> {(x1 - x0) * zoom}x{(y1 - y0) * zoom}')


main()
