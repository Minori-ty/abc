import json, re, os, time, urllib.request

URL = "http://127.0.0.1:3845/mcp"
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "figma_out", "ctx2")
os.makedirs(OUT, exist_ok=True)


def post(payload, sid=None, timeout=25):
    data = json.dumps(payload).encode()
    req = urllib.request.Request(URL, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/event-stream")
    if sid:
        req.add_header("mcp-session-id", sid)
    resp = urllib.request.urlopen(req, timeout=timeout)
    return (resp.headers.get("mcp-session-id") or sid), \
        "\n".join(l[6:] for l in resp.read().decode("utf-8", "replace").splitlines() if l.startswith("data: "))


def build_todo():
    """Nodes worth fetching: any non-instance/non-symbol node whose parent is a
    screen frame or an instance (so each subtree is covered without redundancy)."""
    lines = open(os.path.join(HERE, "meta_now.txt"), encoding="utf-8").read().splitlines()
    stack = []  # (indent, id, name, type)
    todo = []
    for ln in lines:
        m = re.match(r'\s*<(\w+) id="([^"]+)" name="([^"]*)"', ln)
        if not m:
            continue
        ind = len(ln) - len(ln.lstrip())
        typ, nid, name = m.group(1), m.group(2), m.group(3)
        while stack and stack[-1][0] >= ind:
            stack.pop()
        parent = stack[-1] if stack else None
        if typ not in ("instance", "symbol") and parent is not None:
            if parent[3] == "frame" or parent[3] == "instance":
                if parent[3] == "instance" or ind <= 8 or parent[2] in (
                        "Info", "Text", "Row", "Track"):
                    todo.append((nid, name))
        stack.append((ind, nid, name, typ))
    return todo


def main():
    todo = build_todo()
    print("todo", len(todo), flush=True)
    sid, _ = post({"jsonrpc": "2.0", "id": 1, "method": "initialize",
                   "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                              "clientInfo": {"name": "wb", "version": "1.0"}}}, timeout=20)
    post({"jsonrpc": "2.0", "method": "notifications/initialized"}, sid, timeout=20)
    ok = fail = 0
    for i, (nid, name) in enumerate(todo, 1):
        fn = os.path.join(OUT, nid.replace(":", "-") + ".txt")
        if os.path.exists(fn) and os.path.getsize(fn) > 100:
            ok += 1
            continue
        try:
            _, body = post({"jsonrpc": "2.0", "id": 9, "method": "tools/call",
                            "params": {"name": "get_design_context",
                                       "arguments": {"nodeId": nid,
                                                     "clientLanguages": "dart",
                                                     "clientFrameworks": "flutter",
                                                     "excludeScreenshot": True}}}, sid, timeout=20)
            d = json.loads(body)
            txt = "\n".join(x["text"] for x in d["result"]["content"] if x.get("type") == "text")
            if d.get("error") or not txt:
                raise RuntimeError(str(d.get("error")))
            open(fn, "w", encoding="utf-8").write(txt)
            ok += 1
        except Exception as e:
            fail += 1
            print("FAIL", nid, name, str(e)[:60], flush=True)
        if i % 25 == 0:
            print(f"progress {i}/{len(todo)} ok={ok} fail={fail}", flush=True)
    print(f"DONE ok={ok} fail={fail}", flush=True)


if __name__ == "__main__":
    main()
