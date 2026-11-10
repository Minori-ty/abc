import json, sys, os, urllib.request

URL = "http://127.0.0.1:3845/mcp"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "figma_out")
os.makedirs(OUT, exist_ok=True)


def post(payload, sid=None):
    data = json.dumps(payload).encode()
    req = urllib.request.Request(URL, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/event-stream")
    if sid:
        req.add_header("mcp-session-id", sid)
    resp = urllib.request.urlopen(req, timeout=420)
    new_sid = resp.headers.get("mcp-session-id")
    body = resp.read().decode("utf-8", "replace")
    lines = [l[6:] for l in body.splitlines() if l.startswith("data: ")]
    return new_sid or sid, "\n".join(lines)


def call(tool, args, sid):
    _, body = post({"jsonrpc": "2.0", "id": 9, "method": "tools/call",
                    "params": {"name": tool, "arguments": args}}, sid)
    if not body:
        return "EMPTY"
    d = json.loads(body)
    if "error" in d:
        return "ERROR: " + json.dumps(d["error"], ensure_ascii=False)
    parts = []
    for item in d["result"].get("content", []):
        if item.get("type") == "text":
            parts.append(item["text"])
        elif item.get("type") == "image":
            fn = os.path.join(OUT, args.get("nodeId", "x").replace(":", "-") + ".png")
            import base64
            with open(fn, "wb") as f:
                f.write(base64.b64decode(item["data"]))
            parts.append("[IMAGE] " + fn)
    return "\n".join(parts)


def main():
    tool = sys.argv[1]
    extra = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
    ids = sys.argv[3].split(",") if len(sys.argv) > 3 else [""]
    sid, _ = post({"jsonrpc": "2.0", "id": 1, "method": "initialize",
                   "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                              "clientInfo": {"name": "wb", "version": "1.0"}}})
    post({"jsonrpc": "2.0", "method": "notifications/initialized"}, sid)
    for nid in ids:
        args = dict(extra)
        if nid:
            args["nodeId"] = nid.replace("-", ":")
        out = call(tool, args, sid)
        fn = os.path.join(OUT, tool + "__" + (nid or "all").replace(":", "-") + ".txt")
        with open(fn, "w", encoding="utf-8") as f:
            f.write(out)
        print(tool, nid or "all", "->", len(out), "chars")


if __name__ == "__main__":
    main()
