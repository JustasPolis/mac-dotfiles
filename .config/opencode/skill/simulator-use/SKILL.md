---
name: simulator-use
description: Launch, control, and interact with iOS Simulator using simctl and axe CLI. Use when asked to "boot simulator", "launch app", "tap button", "type text", "scroll", "check screen", "describe UI", "take screenshot", "open deep link", "send push notification", "grant permissions", "install app", "interact with simulator", or any request to manipulate the iOS Simulator. Also trigger on `/simulator-use`.
---

# iOS Simulator Interaction

Control the iOS Simulator with `xcrun simctl` (device/app management) and `axe` (UI interaction via accessibility).

## Workflow

### 1. Get a Booted Simulator

```bash
xcrun simctl list devices | grep Booted
```

**Multiple simulators may be booted.** Always check and confirm which one to target. Extract the correct UDID and **use it explicitly in every command** — never rely on `booted` keyword when multiple simulators are running.

If none booted:
```bash
xcrun simctl list devices available | grep iPhone
xcrun simctl boot <UDID>
```

Store UDID for all subsequent commands.

### 2. Prepare Environment

```bash
# Grant permissions to avoid system prompts
xcrun simctl privacy booted grant photos <BUNDLE_ID>
xcrun simctl privacy booted grant location <BUNDLE_ID>
xcrun simctl privacy booted grant microphone <BUNDLE_ID>

# Set location if needed
xcrun simctl location booted set 55.6761,12.5683
```

### 3. Launch / Relaunch App

```bash
xcrun simctl terminate booted <BUNDLE_ID>
xcrun simctl launch booted <BUNDLE_ID>
```

Or navigate via deep link:
```bash
xcrun simctl openurl booted "myapp://target-screen"
```

### 4. Read Screen State (always do before interacting)

```bash
axe describe-ui --udid <UDID>
```

Returns accessibility hierarchy with `AXUniqueId` and `AXLabel` values for targeting taps.

### 5. Interact

```bash
# Tap by accessibility identifier (preferred)
axe tap --id "login_button" --udid <UDID>

# Tap by label
axe tap --label "Sign In" --udid <UDID>

# Tap by coordinates
axe tap -x 200 -y 400 --udid <UDID>

# Type into focused field
axe type "user@example.com" --udid <UDID>

# Scroll
axe gesture scroll-down --udid <UDID>
axe gesture scroll-up --udid <UDID>

# Back navigation
axe gesture swipe-from-left-edge --udid <UDID>

# Press hardware buttons
axe button home --udid <UDID>
```

### 6. Verify Result

After each interaction, read UI again:
```bash
axe describe-ui --udid <UDID>
```

Take screenshot for visual verification:
```bash
xcrun simctl io booted screenshot /tmp/result.png
```

## Rules

1. **Always `describe-ui` before tapping** — never guess element positions
2. **Use `--id` over `--label`** — identifiers are more stable than display text
3. **Add delays for transitions** — use `--post-delay 0.5` when app needs animation time
4. **Read UI after each interaction** — verify before proceeding
5. **Grant permissions upfront** — prevents alert dialogs from breaking flow
6. **NEVER uninstall, reinstall, erase, or clear app cache/data without explicit user permission** — this destroys login state, local data, and may require lengthy re-setup. Always ask first.

## Reference Files

- **`references/simctl.md`** — Full simctl reference: devices, apps, permissions, push, screenshots, media
- **`references/axe.md`** — Full axe reference: tap, type, swipe, gestures, keys, combos, touch events
