import json, re, os, sys, time, urllib.request

URL = "http://127.0.0.1:3845/mcp"
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "figma_out", "ctx")
os.makedirs(OUT, exist_ok=True)


def post(payload, sid=None, timeout=45):
    data = json.dumps(payload).encode()
    req = urllib.request.Request(URL, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/event-stream")
    if sid:
        req.add_header("mcp-session-id", sid)
    resp = urllib.request.urlopen(req, timeout=timeout)
    return (resp.headers.get("mcp-session-id") or sid), \
        "\n".join(l[6:] for l in resp.read().decode("utf-8", "replace").splitlines() if l.startswith("data: "))


def call(tool, args, sid):
    _, body = post({"jsonrpc": "2.0", "id": 9, "method": "tools/call",
                    "params": {"name": tool, "arguments": args}}, sid)
    if not body:
        return None, "EMPTY"
    d = json.loads(body)
    if "error" in d:
        return None, json.dumps(d["error"], ensure_ascii=False)
    texts = [i["text"] for i in d["result"].get("content", []) if i.get("type") == "text"]
    return "\n".join(texts), None


def main():
    meta = open(os.path.join(HERE, "meta_now.txt"), encoding="utf-8").read().splitlines()
    todo, cur = [], None
    for ln in meta:
        m = re.match(r'\s*<(\w+) id="([^"]+)" name="([^"]*)"', ln)
        if not m:
            continue
        ind = len(ln) - len(ln.lstrip())
        if ind == 4 and m.group(1) == "frame":
            cur = m.group(2)
        elif ind == 6 and cur:
            todo.append((m.group(2), cur))

    sid, _ = post({"jsonrpc": "2.0", "id": 1, "method": "initialize",
                   "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                              "clientInfo": {"name": "wb", "version": "1.0"}}}, timeout=30)
    post({"jsonrpc": "2.0", "method": "notifications/initialized"}, sid, timeout=30)

    done = ok = fail = 0
    for nid, frame in todo:
        fn = os.path.join(OUT, nid.replace(":", "-") + ".txt")
        if os.path.exists(fn) and os.path.getsize(fn) > 200:
            done += 1
            continue
        txt = None
        for attempt in range(1):
            try:
                txt, err = call("get_design_context",
                                {"nodeId": nid, "clientLanguages": "dart",
                                 "clientFrameworks": "flutter",
                                 "excludeScreenshot": True}, sid)
                if txt:
                    break
            except Exception as e:
                err = str(e)
                time.sleep(1.5)
        if txt:
            open(fn, "w", encoding="utf-8").write(txt)
            ok += 1
        else:
            fail += 1
            print("FAIL", nid, frame, err, flush=True)
        done += 1
        if done % 10 == 0:
            print(f"progress {done}/{len(todo)} ok={ok} fail={fail}", flush=True)
    print(f"DONE total={len(todo)} ok={ok} fail={fail}", flush=True)


if __name__ == "__main__":
    main()
