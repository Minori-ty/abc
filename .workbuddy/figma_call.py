import json, sys, urllib.request

URL = "http://127.0.0.1:3845/mcp"


def post(payload, sid=None):
    data = json.dumps(payload).encode()
    req = urllib.request.Request(URL, data=data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Accept", "application/json, text/event-stream")
    if sid:
        req.add_header("mcp-session-id", sid)
    resp = urllib.request.urlopen(req, timeout=120)
    new_sid = resp.headers.get("mcp-session-id")
    body = resp.read().decode("utf-8", "replace")
    out = []
    for line in body.splitlines():
        if line.startswith("data: "):
            out.append(line[6:])
    return new_sid or sid, "\n".join(out)


def main():
    tool = sys.argv[1]
    args = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
    sid, _ = post({
        "jsonrpc": "2.0", "id": 1, "method": "initialize",
        "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                   "clientInfo": {"name": "wb", "version": "1.0"}},
    })
    post({"jsonrpc": "2.0", "method": "notifications/initialized"}, sid)
    _, body = post({"jsonrpc": "2.0", "id": 2, "method": "tools/call",
                    "params": {"name": tool, "arguments": args}}, sid)
    if not body:
        print("EMPTY RESPONSE")
        return
    d = json.loads(body)
    if "error" in d:
        print("ERROR:", json.dumps(d["error"], ensure_ascii=False))
        return
    for item in d["result"].get("content", []):
        if item.get("type") == "text":
            print(item["text"])
        else:
            print(json.dumps(item)[:400])


if __name__ == "__main__":
    main()
