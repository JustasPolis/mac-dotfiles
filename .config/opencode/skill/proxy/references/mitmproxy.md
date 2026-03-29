# mitmproxy Reference

## Overview

mitmproxy intercepts, inspects, and modifies HTTP/HTTPS traffic between the iOS simulator and backend servers. Use `mitmdump` (headless CLI) for automation.

## Running mitmdump

### Basic

```bash
mitmdump                    # Default port 8080
mitmdump -p 9090            # Custom port
mitmdump -q                 # Quiet mode
mitmdump -q -s script.py    # Quiet + script
```

### Filtering Traffic

```bash
mitmdump --set flow_detail=2 "~d api.example.com"
mitmdump "~u /api/v1/"
mitmdump "~t json"
mitmdump "~d api.example.com & ~u /graphql"
```

### Filter Syntax

| Filter | Meaning |
|--------|---------|
| `~d domain` | Match domain |
| `~u regex` | Match URL |
| `~m METHOD` | Match HTTP method |
| `~s` | Match responses |
| `~q` | Match requests |
| `~t content-type` | Match content type |
| `~c code` | Match status code |
| `~b regex` | Match body content |
| `~h regex` | Match header |
| `&` | AND |
| `\|` | OR |
| `!` | NOT |

## Script Patterns

### Log All Traffic

```python
import json
from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    print(f">>> {flow.request.method} {flow.request.pretty_url}")
    if flow.request.content:
        try:
            print(f"    Body: {json.dumps(json.loads(flow.request.content), indent=2)[:500]}")
        except: pass

def response(flow: http.HTTPFlow) -> None:
    print(f"<<< {flow.response.status_code} {flow.request.pretty_url}")
```

### Modify Response Body

```python
import json
from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    if "/endpoint" not in flow.request.path:
        return
    data = json.loads(flow.response.content)
    data["field"] = "overridden"
    flow.response.content = json.dumps(data).encode()
```

### Mock Response (No Server Hit)

```python
import json
from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    if flow.request.path == "/api/target":
        flow.response = http.Response.make(
            200,
            json.dumps({"mocked": True}),
            {"Content-Type": "application/json"}
        )
```

### GraphQL Operation Routing

```python
import json
from mitmproxy import http

MOCKS = {
    "GetUser": {"data": {"user": {"id": "1", "name": "Test"}}},
    "GetPodcast": {"data": {"podcast": {"id": "42", "title": "Mock"}}},
}

def request(flow: http.HTTPFlow) -> None:
    if "/graphql" not in flow.request.path:
        return
    try:
        body = json.loads(flow.request.content)
        op = body.get("operationName", "")
        if op in MOCKS:
            flow.response = http.Response.make(
                200, json.dumps(MOCKS[op]), {"Content-Type": "application/json"}
            )
    except: pass
```

### Simulate Errors

```python
from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    if "/flaky" in flow.request.path:
        flow.response = http.Response.make(500, b"Internal Server Error")
```

### Simulate Slow Network

```python
import time
from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    if "api.example.com" in flow.request.pretty_host:
        time.sleep(3)
```

## Recording and Replaying

```bash
mitmdump -w traffic.flow                                    # Record
mitmdump --server-replay traffic.flow                       # Replay
mitmdump --server-replay traffic.flow --set server_replay_nopop=true   # Keep after serving
mitmdump --server-replay traffic.flow --set server_replay_kill_extra=true  # Kill unmatched
```

## Background Process

```bash
mitmdump -q -s script.py &
MITM_PID=$!
# ... run tests ...
kill $MITM_PID
```

## Troubleshooting

- **SSL errors**: Ensure CA cert installed via `xcrun simctl keychain booted add-root-cert`
- **No traffic**: Verify proxy settings on simulator
- **Certificate pinning**: Apps with cert pinning reject mitmproxy CA — cannot bypass without app modification
- **Port conflict**: Use `-p` for different port
