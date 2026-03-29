# mitmproxy Reference

## Overview

mitmproxy intercepts, inspects, and modifies HTTP/HTTPS traffic between the iOS simulator and backend servers. Use `mitmdump` (headless CLI) for automation.

## Simulator Proxy Setup

### 1. Configure Simulator HTTP Proxy

```bash
# Set proxy on booted simulator (port 8080 is mitmproxy default)
xcrun simctl spawn booted defaults write -g HTTP_PROXY_HOST 127.0.0.1
xcrun simctl spawn booted defaults write -g HTTP_PROXY_PORT 8080
xcrun simctl spawn booted defaults write -g HTTPS_PROXY_HOST 127.0.0.1
xcrun simctl spawn booted defaults write -g HTTPS_PROXY_PORT 8080
```

### 2. Install mitmproxy CA Certificate

For HTTPS interception, the simulator must trust mitmproxy's CA:

```bash
# Ensure mitmproxy has generated certificates (run once)
mitmdump --help > /dev/null 2>&1

# Install CA cert to simulator
xcrun simctl keychain booted add-root-cert ~/.mitmproxy/mitmproxy-ca-cert.pem
```

### 3. Remove Proxy When Done

```bash
xcrun simctl spawn booted defaults delete -g HTTP_PROXY_HOST
xcrun simctl spawn booted defaults delete -g HTTP_PROXY_PORT
xcrun simctl spawn booted defaults delete -g HTTPS_PROXY_HOST
xcrun simctl spawn booted defaults delete -g HTTPS_PROXY_PORT
```

## Running mitmdump

### Basic Proxy

```bash
# Start proxy on default port 8080
mitmdump

# Custom port
mitmdump -p 9090

# Quiet mode (less output)
mitmdump -q
```

### Filtering Traffic

```bash
# Only intercept specific domains
mitmdump --set flow_detail=2 "~d api.example.com"

# Filter by URL path
mitmdump "~u /api/v1/"

# Filter by content type
mitmdump "~t json"

# Combine filters
mitmdump "~d api.example.com & ~u /graphql"
```

### Filter Syntax Quick Reference

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

## Scripting with mitmdump

### Inline Script: Modify Response Body

Create a Python script to intercept and modify responses:

```python
# modify_response.py
import json
from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    # Only modify specific endpoints
    if "api.example.com" not in flow.request.pretty_host:
        return
    if "/endpoint" not in flow.request.path:
        return

    # Parse and modify JSON response
    data = json.loads(flow.response.content)
    data["field"] = "overridden_value"
    flow.response.content = json.dumps(data).encode()
```

Run:
```bash
mitmdump -s modify_response.py
```

### Return Mock Response (No Server Hit)

```python
# mock_endpoint.py
import json
from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    if flow.request.path == "/api/v1/target-endpoint":
        flow.response = http.Response.make(
            200,
            json.dumps({"mocked": True, "data": "fake"}),
            {"Content-Type": "application/json"}
        )
```

### Modify Request Before Sending

```python
# modify_request.py
import json
from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    # Add/modify headers
    flow.request.headers["X-Custom-Header"] = "value"

    # Modify query parameters
    if "/search" in flow.request.path:
        flow.request.query["override_param"] = "new_value"

    # Modify request body
    if flow.request.method == "POST" and "/api/submit" in flow.request.path:
        data = json.loads(flow.request.content)
        data["injected_field"] = "value"
        flow.request.content = json.dumps(data).encode()
```

### Simulate Network Errors

```python
# simulate_errors.py
from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    if "/flaky-endpoint" in flow.request.path:
        flow.response = http.Response.make(500, b"Internal Server Error")
```

### Simulate Slow Network

```python
# slow_network.py
import time
from mitmproxy import http

def response(flow: http.HTTPFlow) -> None:
    if "api.example.com" in flow.request.pretty_host:
        time.sleep(3)  # Add 3 second delay
```

### Log All Requests

```python
# log_traffic.py
from mitmproxy import http
import json

def request(flow: http.HTTPFlow) -> None:
    print(f">>> {flow.request.method} {flow.request.pretty_url}")
    if flow.request.content:
        try:
            body = json.loads(flow.request.content)
            print(f"    Body: {json.dumps(body, indent=2)[:500]}")
        except:
            pass

def response(flow: http.HTTPFlow) -> None:
    print(f"<<< {flow.response.status_code} {flow.request.pretty_url}")
```

### Conditional Mock Based on Request Body (GraphQL)

```python
# mock_graphql.py
import json
from mitmproxy import http

MOCKS = {
    "GetUser": {"data": {"user": {"id": "1", "name": "Test User"}}},
    "GetPodcast": {"data": {"podcast": {"id": "42", "title": "Mock Podcast"}}},
}

def request(flow: http.HTTPFlow) -> None:
    if "/graphql" not in flow.request.path:
        return
    try:
        body = json.loads(flow.request.content)
        operation = body.get("operationName", "")
        if operation in MOCKS:
            flow.response = http.Response.make(
                200,
                json.dumps(MOCKS[operation]),
                {"Content-Type": "application/json"}
            )
    except:
        pass
```

## Recording and Replaying

```bash
# Record traffic to file
mitmdump -w traffic.flow

# Replay recorded traffic (server replay - responds to matching requests)
mitmdump --server-replay traffic.flow

# Replay with options
mitmdump --server-replay traffic.flow --set server_replay_nopop=true  # Don't remove after serving
mitmdump --server-replay traffic.flow --set server_replay_kill_extra=true  # Kill unmatched requests
```

## Running as Background Process

```bash
# Start in background
mitmdump -q -s script.py &
MITM_PID=$!

# ... run tests ...

# Stop proxy
kill $MITM_PID
```

## Troubleshooting

- **SSL errors**: Ensure CA cert is installed via `xcrun simctl keychain booted add-root-cert`
- **No traffic captured**: Verify proxy settings are configured on the simulator
- **Certificate pinning**: Apps with certificate pinning will reject mitmproxy's CA. This cannot be bypassed on the simulator without modifying the app.
- **Port conflict**: Use `-p` to pick a different port if 8080 is in use
