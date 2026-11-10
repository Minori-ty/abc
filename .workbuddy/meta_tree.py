"""Parse .workbuddy/meta_now.txt (Figma get_metadata output) into a queryable tree.

Coordinates in the source file are parent-relative. `abs_pos` walks the chain to
produce frame-absolute coordinates, which is what the Flutter `Stack` needs.
"""
import json
import re
import sys

META = '.workbuddy/meta_now.txt'
OPEN_RE = re.compile(
    r'<([\w-]+) id="([^"]+)" name="([^"]*)" x="([-\d.eE]+)" y="([-\d.eE]+)" '
    r'width="([-\d.eE]+)" height="([-\d.eE]+)"'
)
CLOSE_RE = re.compile(r'</([\w-]+)>')


def load():
    root = {'tag': 'root', 'id': 'root', 'name': 'root',
            'x': 0.0, 'y': 0.0, 'w': 0.0, 'h': 0.0, 'children': []}
    stack = [root]
    for line in open(META, encoding='utf-8'):
        line = line.strip()
        if not line:
            continue
        if CLOSE_RE.match(line):
            if len(stack) > 1:
                stack.pop()
            continue
        m = OPEN_RE.match(line)
        if not m:
            continue
        tag, nid, name, x, y, w, h = m.groups()
        node = {'tag': tag, 'id': nid, 'name': name,
                'x': float(x), 'y': float(y), 'w': float(w), 'h': float(h),
                'children': []}
        stack[-1]['children'].append(node)
        if not line.endswith('/>'):
            stack.append(node)
    return root


def index(root):
    out = {}

    def walk(n):
        out[n['id']] = n
        for c in n['children']:
            walk(c)
    walk(root)
    return out


def frames(root):
    out = {}

    def walk(n):
        if n['tag'] == 'frame' and n['w'] == 412 and n['h'] == 892:
            out[n['id']] = n
        for c in n['children']:
            walk(c)
    walk(root)
    return out


def abs_pos(nodes, nid, ox=0.0, oy=0.0):
    """Absolute offset of `nid` inside its frame."""
    n = nodes[nid]
    return ox + n['x'], oy + n['y']


def flatten(frame, depth=0, ox=0.0, oy=0.0, out=None):
    if out is None:
        out = []
    for c in frame['children']:
        ax, ay = ox + c['x'], oy + c['y']
        out.append((depth, c, ax, ay))
        flatten(c, depth + 1, ax, ay, out)
    return out


def dump(fid):
    root = load()
    fr = frames(root)
    if fid not in fr:
        print('frame not found', fid)
        return
    f = fr[fid]
    print(f"{f['id']} {f['name']} {f['w']}x{f['h']}")
    for depth, n, ax, ay in flatten(f):
        print('  ' * (depth + 1) +
              f"{n['tag']:<8} {n['id']:<9} {n['name'][:34]:<34} "
              f"@({ax:g},{ay:g}) {n['w']:g}x{n['h']:g}")


if __name__ == '__main__':
    for arg in sys.argv[1:]:
        dump(arg)
        print()
