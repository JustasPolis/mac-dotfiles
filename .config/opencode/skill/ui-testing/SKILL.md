---
name: ui-testing
description: 'iOS UI testing with simulator interaction and network mocking. Use when asked to: (1) test UI flows or screens on iOS Simulator, (2) interact with simulator (tap, type, swipe, scroll), (3) intercept, mock, or override network requests, (4) verify UI state or accessibility elements, (5) simulate push notifications or deep links, (6) record or screenshot simulator, (7) "run UI test", "test this flow", "mock API response", "tap on button", "check what is on screen", or any variation of manual/automated iOS UI testing.'
---

# iOS UI Testing

Test iOS apps on Simulator by interacting with UI via `axe`, controlling the simulator via `simctl`, and intercepting network traffic via `mitmproxy`.

## Tools

| Tool | Purpose |
|------|---------|
| `axe` | Read UI hierarchy, tap elements, type text, swipe, press buttons |
| `xcrun simctl` | Boot/manage simulators, install apps, permissions, deep links, push |
| `mitmdump` | Intercept/mock/modify HTTP(S) traffic between app and servers |

## Workflow

### Step 1: Create or Reuse a Branch Simulator

Always use a **dedicated simulator named after the current git branch**. This avoids proxy/state conflicts with other sessions.

```bash
# 1. Get the current branch name
BRANCH=$(git branch --show-current)

# 2. Check if a simulator with that name already exists
UDID=$(xcrun simctl list devices -j 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for devs in data['devices'].values():
    for d in devs:
        if d['name'] == '$BRANCH':
            print(d['udid']); break
" 2>/dev/null)

# 3. Create if it doesn't exist (iPhone 17 Pro, iOS 26.2 by default)
if [ -z "$UDID" ]; then
    UDID=$(xcrun simctl create "$BRANCH" "iPhone 17 Pro" "com.apple.CoreSimulator.SimRuntime.iOS-26-2")
    echo "Created simulator '$BRANCH' with UDID: $UDID"
fi

# 4. Boot it (safe to call if already booted)
xcrun simctl boot "$UDID" 2>/dev/null

# 5. Open the Simulator GUI (boot alone runs headless)
open -a Simulator

echo "Using simulator '$BRANCH' ($UDID)"
```

Store the UDID for all subsequent commands. Pass it to build commands:
```bash
make build SIMULATOR_ID=$UDID
make run SIMULATOR_ID=$UDID
```

### Step 2: Set Up Network Interception (if needed)

Only when testing requires mocked, modified, or observed network traffic. See `references/mitmproxy.md` for full setup and scripting patterns.

1. Write a Python script for the desired interception (mock response, modify request, log traffic, etc.)
2. Start mitmdump: `mitmdump -q -s script.py &`
3. Configure simulator proxy:
   ```bash
   xcrun simctl spawn booted defaults write -g HTTP_PROXY_HOST 127.0.0.1
   xcrun simctl spawn booted defaults write -g HTTP_PROXY_PORT 8080
   xcrun simctl spawn booted defaults write -g HTTPS_PROXY_HOST 127.0.0.1
   xcrun simctl spawn booted defaults write -g HTTPS_PROXY_PORT 8080
   ```
4. Install CA cert: `xcrun simctl keychain booted add-root-cert ~/.mitmproxy/mitmproxy-ca-cert.pem`

### Step 3: Prepare Simulator State

Use `simctl` to set up the test environment:

```bash
# Grant permissions (avoid system prompts interrupting test)
xcrun simctl privacy booted grant photos <BUNDLE_ID>
xcrun simctl privacy booted grant location <BUNDLE_ID>

# Set location if needed
xcrun simctl location booted set 55.6761,12.5683

# Open a deep link to navigate to specific screen
xcrun simctl openurl booted "myapp://target-screen"
```

See `references/simctl.md` for full reference.

### Step 4: Observe Screen State

Always read the UI before interacting:

```bash
axe describe-ui --udid <UDID>
```

This returns the accessibility hierarchy. Use element `AXUniqueId` or `AXLabel` values for targeted taps.

### Step 5: Interact with the App

Use `axe` to drive the UI. See `references/axe.md` for full command reference.

```bash
# Tap by accessibility identifier
axe tap --id "login_button" --udid <UDID>

# Tap by label
axe tap --label "Sign In" --udid <UDID>

# Type into focused field
axe type "user@example.com" --udid <UDID>

# Scroll down
axe gesture scroll-down --udid <UDID>

# Press hardware button
axe button home --udid <UDID>
```

### Step 6: Verify State

After each interaction, read the UI again to verify the result:

```bash
axe describe-ui --udid <UDID>
```

Check that expected elements are present, text content is correct, and navigation occurred as expected. Take a screenshot for visual verification:

```bash
xcrun simctl io booted screenshot /tmp/test_result.png
```

### Step 7: Cleanup

```bash
# Stop mitmproxy (if started)
kill $MITM_PID

# Remove proxy settings
xcrun simctl spawn $UDID defaults delete -g HTTP_PROXY_HOST
xcrun simctl spawn $UDID defaults delete -g HTTP_PROXY_PORT
xcrun simctl spawn $UDID defaults delete -g HTTPS_PROXY_HOST
xcrun simctl spawn $UDID defaults delete -g HTTPS_PROXY_PORT

# Reset permissions if needed
xcrun simctl privacy $UDID reset all <BUNDLE_ID>

# Delete the branch simulator (frees resources)
xcrun simctl shutdown "$UDID" 2>/dev/null
xcrun simctl delete "$UDID"
echo "Deleted branch simulator '$BRANCH'"
```

## Agent Rules

1. **Always `describe-ui` before tapping** - never guess element positions or identifiers
2. **Use `--id` over `--label` for taps** - identifiers are more stable than display text
3. **Add delays between rapid interactions** - use `--post-delay 0.5` when the app needs time for transitions
4. **Read UI after each interaction** - verify the interaction had the expected effect before proceeding
5. **Write mitmproxy scripts to files** - create `.py` files and pass to `mitmdump -s`, don't try inline Python
6. **Clean up proxy settings** - always remove proxy config after testing to avoid breaking the simulator
7. **Grant permissions before test flow** - use `simctl privacy grant` to prevent alert dialogs from interrupting
8. **Use `--post-delay` generously** - UI transitions, network requests, and animations take time

## Reference Files

- **`references/axe.md`** - Full axe CLI reference: all commands, arguments, interaction patterns
- **`references/mitmproxy.md`** - mitmproxy setup, scripting, request/response modification, GraphQL mocking
- **`references/simctl.md`** - simctl reference: device management, app lifecycle, permissions, push, deep links
