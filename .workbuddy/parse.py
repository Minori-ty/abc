import json, re, os, glob

HERE = os.path.dirname(os.path.abspath(__file__))
CTX = [os.path.join(HERE, "figma_out", "ctx2"), os.path.join(HERE, "figma_out")]

VAR = {
    "fg": "fg", "card": "card", "bg": "bg", "muted": "muted", "mutedfg": "mutedFg",
    "border": "border", "primary": "primary", "primarytext": "primaryText",
    "primarysoft": "primarySoft", "onprimary": "onPrimary", "accent": "accent",
    "accenttext": "accentText", "accentsoft": "accentSoft", "warning": "warning",
    "warningtext": "warningText", "destructive": "destructive",
    "destructivetext": "destructiveText", "destructivesoft": "destructiveSoft",
    "scrim": "scrim", "white": "white", "ink": "ink",
}


def var_color(s):
    """bg-[var(--color\/primary,#2563eb)] -> (token, hex)"""
    m = re.search(r'var\(--color\\?/([a-z]+),([^)]+)\)', s, re.I)
    if m:
        return VAR.get(m.group(1).lower()), m.group(2)
    m = re.search(r'\[(#[0-9a-fA-F]{3,8})\]', s)
    if m:
        return None, m.group(1)
    m = re.search(r'\[(rgba?\([^\]]+)\]', s)
    if m:
        return None, m.group(1)
    return None, None


def cls_attrs(cm):
    out = {}
    # background
    for m in re.finditer(r'(?:^|\s)bg-\[([^\]]+)\]', cm):
        out.setdefault("bg", var_color(m.group(1)))
    # border
    if re.search(r'(?:^|\s)border(?:\s|$)', cm) or re.search(r'border-\[', cm):
        m = re.search(r'border-\[([^\]]+)\]', cm)
        out["border"] = var_color(m.group(1)) if m else (None, "#e4ecfc")
    if re.search(r'\bborder-t\b', cm) and "border" not in out:
        out["border_t"] = True
    # radius
    m = re.search(r'rounded-\[([^\]]+)\]', cm)
    if m:
        v = m.group(1)
        r = re.search(r'(\d+(?:\.\d+)?)px', v) or re.search(r'var\(--radius\\?/\w+,(\d+(?:\.\d+)?)px\)', v)
        out["radius"] = float(r.group(1)) if r else 999.0
    elif "rounded-full" in cm:
        out["radius"] = 999.0
    # shadow
    m = re.search(r'shadow-\[([^\]]+)\]', cm)
    if m:
        out["shadow"] = m.group(1)
    # font
    m = re.search(r"font-\['([^']+)'\]", cm)
    if m:
        out["font"] = m.group(1)
    m = re.search(r'text-\[(\d+(?:\.\d+)?)px\]', cm)
    if m:
        out["size"] = float(m.group(1))
    m = re.search(r'leading-\[([^\]]+)\]', cm)
    if m:
        out["leading"] = m.group(1)
    m = re.search(r'text-\[color:([^\]]+)\]', cm)
    if m:
        out["color"] = var_color(m.group(1))
    m = re.search(r'opacity-\[([^\]]+)\]', cm)
    if m:
        out["opacity"] = m.group(1)
    if "text-center" in cm:
        out["align"] = "center"
    if "text-right" in cm:
        out["align"] = "right"
    m = re.search(r'\bitems-([a-z]+)', cm)
    if m:
        out["items"] = m.group(1)
    m = re.search(r'\bjustify-([a-z]+)', cm)
    if m:
        out["justify"] = m.group(1)
    m = re.search(r'\bgap-\[([^\]]+)\]', cm)
    if m:
        out["gap"] = m.group(1)
    for side, pat in (("p", r'\bp-\[([^\]]+)\]'), ("px", r'\bpx-\[([^\]]+)\]'),
                      ("py", r'\bpy-\[([^\]]+)\]')):
        m = re.search(pat, cm)
        if m:
            out[side] = m.group(1)
    for pat, key in ((r'\bw-\[([^\]]+)\]', "w"), (r'\bh-\[([^\]]+)\]', "h"),
                     (r'\bsize-\[([^\]]+)\]', "size")):
        m = re.search(pat, cm)
        if m:
            out[key] = m.group(1)
    return out


ELEM = re.compile(r'<(div|p|img|span)\s([^>]*?)/?>', re.S)


def parse_file(path):
    txt = open(path, encoding="utf-8").read()
    consts = dict(re.findall(r'const (img\w+) = "([^"]+)"', txt))
    nodes = {}
    for m in ELEM.finditer(txt):
        tag, attrs = m.group(1), m.group(2)
        nid = re.search(r'data-node-id="([^"]+)"', attrs)
        if not nid:
            continue
        nid = nid.group(1)
        name = re.search(r'data-name="([^"]*)"', attrs)
        cm = re.search(r'className=(?:"([^"]*)"|\{className \|\| "([^"]*)"\})', attrs)
        cm = (cm.group(1) or cm.group(2)) if cm else ""
        rec = {"id": nid, "name": name.group(1) if name else "", "tag": tag}
        rec.update(cls_attrs(cm))
        if tag == "p":
            start = m.end()
            end = txt.find("</p>", start)
            rec["text"] = re.sub(r'\s+', ' ', txt[start:end]).strip()
        if tag == "img":
            src = re.search(r'src=\{(\w+)\}', attrs)
            if src:
                rec["img"] = consts.get(src.group(1), src.group(1))
        nodes[nid] = rec
    return nodes


def main():
    merged = {}
    for d in CTX:
        for f in sorted(glob.glob(os.path.join(d, "*.txt"))):
            base = os.path.basename(f)
            if base.startswith("get_design_context__"):
                base = base.replace("get_design_context__", "")
            nid = base.replace(".txt", "").replace("-", ":")
            try:
                if "Rate limit" in open(f, encoding="utf-8").read(200):
                    continue
            except Exception:
                continue
            for k, v in parse_file(f).items():
                if k not in merged or len(json.dumps(v)) > len(json.dumps(merged[k])):
                    merged[k] = v
    out = os.path.join(HERE, "spec.json")
    json.dump(merged, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("nodes", len(merged))


if __name__ == "__main__":
    main()
