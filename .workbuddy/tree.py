import json, re, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = json.load(open(os.path.join(HERE, "spec.json"), encoding="utf-8"))
lines = open(os.path.join(HERE, "meta_now.txt"), encoding="utf-8").read().splitlines()

frames = {}
cur = None
stack = []
for ln in lines:
    m = re.match(r'\s*<(\w+) id="([^"]+)" name="([^"]*)" x="(-?[\d.]+)" y="(-?[\d.]+)" width="([\d.]+)" height="([\d.]+)"', ln)
    if not m:
        continue
    ind = len(ln) - len(ln.lstrip())
    typ, nid, name = m.group(1), m.group(2), m.group(3)
    x, y, w, h = map(float, m.groups()[3:])
    while stack and stack[-1][0] >= ind:
        stack.pop()
    ax, ay = x, y
    for s in stack:
        ax += s[1]
        ay += s[2]
    node = {"ind": ind, "type": typ, "id": nid, "name": name,
            "ax": ax, "ay": ay, "w": w, "h": h, "depth": len(stack)}
    stack.append((ind, x, y))
    if ind == 4 and typ == "frame":
        cur = nid
        frames[cur] = []
        frames[cur + "#origin"] = (ax, ay)
    if cur and ind > 4:
        frames[cur].append(node)

target = sys.argv[1] if len(sys.argv) > 1 else "5:2"
ox, oy = frames.get(target + "#origin", (0, 0))
for n in frames.get(target, []):
    n["ax"] -= ox
    n["ay"] -= oy
    sp = spec.get(n["id"], {})
    bits = []
    if sp.get("bg"):
        bits.append("bg=" + str(sp["bg"][0] or sp["bg"][1]))
    if sp.get("border"):
        bits.append("bd=" + str(sp["border"][0] or sp["border"][1]))
    if sp.get("radius"):
        bits.append("r=" + str(sp["radius"]))
    if sp.get("shadow"):
        bits.append("shadow")
    if sp.get("size"):
        bits.append(str(sp["size"]))
    if sp.get("font"):
        bits.append(sp["font"].split(":")[1][:6])
    if sp.get("leading"):
        bits.append("lh" + sp["leading"])
    if sp.get("color"):
        bits.append("c=" + str(sp["color"][0] or sp["color"][1]))
    if sp.get("text"):
        bits.append('"%s"' % sp["text"][:40])
    if sp.get("img"):
        bits.append("img=" + sp["img"].rsplit("/", 1)[-1][:8])
    print("%s%-9s %-24s @%g,%g %gx%g  %s" % (
        "  " * (n["depth"] - 1), n["id"], n["name"][:24], n["ax"], n["ay"],
        n["w"], n["h"], " ".join(bits)))
