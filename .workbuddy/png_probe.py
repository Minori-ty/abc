import zlib, struct, sys

def load(path):
    d = open(path, 'rb').read()
    pos = 8; idat = b''
    while pos < len(d):
        ln = struct.unpack('>I', d[pos:pos+4])[0]
        typ = d[pos+4:pos+8]; data = d[pos+8:pos+8+ln]; pos += 12+ln
        if typ == b'IHDR': w, h, bd, ct = struct.unpack('>IIBB', data[:10])
        elif typ == b'IDAT': idat += data
        elif typ == b'IEND': break
    raw = zlib.decompress(idat); ch = {0:1,2:3,3:1,4:2,6:4}[ct]; stride = w*ch
    out = bytearray(); prev = bytearray(stride); i = 0
    for _ in range(h):
        f = raw[i]; i += 1; line = bytearray(raw[i:i+stride]); i += stride
        for x in range(stride):
            a = line[x-ch] if x >= ch else 0; b = prev[x]
            c = prev[x-ch] if x >= ch else 0
            if f == 1: line[x] = (line[x]+a) & 255
            elif f == 2: line[x] = (line[x]+b) & 255
            elif f == 3: line[x] = (line[x]+(a+b)//2) & 255
            elif f == 4:
                p = a+b-c; pa, pb, pc = abs(p-a), abs(p-b), abs(p-c)
                pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x]+pr) & 255
        out += line; prev = line
    return w, h, ch, bytes(out)

w, h, ch, px = load(sys.argv[1])
def at(x, y):
    i = (y*w+x)*ch
    return px[i:i+3]
# frame bbox: non-pure-white columns
left = next(x for x in range(w) if at(x, h//2) != b'\xff\xff\xff')
right = next(x for x in range(w-1, 0, -1) if at(x, h//2) != b'\xff\xff\xff')
top = next(y for y in range(h) if at(w//2, y) != b'\xff\xff\xff')
bot = next(y for y in range(h-1, 0, -1) if at(w//2, y) != b'\xff\xff\xff')
scale = (right-left+1)/412
print(f'image {w}x{h} frame=({left},{top})-({right},{bot}) scale={scale:.3f}')

def region(dx, dy, r=10):
    cx = int(left+dx*scale); cy = int(top+dy*scale)
    cols = {}
    for y in range(max(0,cy-r), min(h,cy+r)):
        for x in range(max(0,cx-r), min(w,cx+r)):
            c = at(x,y); cols[c] = cols.get(c,0)+1
    return sorted(cols.items(), key=lambda kv: -kv[1])[:5]

for spec in sys.argv[2:]:
    name, dx, dy = spec.split(',')
    print(f'{name:16s} design({dx},{dy}) ->', [(c.hex(), n) for c, n in region(float(dx), float(dy))])
