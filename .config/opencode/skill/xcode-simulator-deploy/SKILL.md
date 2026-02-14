---
name: xcode-simulator-deploy
description: Build, install, and launch iOS apps on simulator. Use when asked to "build and install", "deploy to simulator", "run on simulator", "install app", "launch app on simulator", or any variation of building an Xcode project and running it on iOS Simulator.
---

# Xcode Simulator Deploy

Build an Xcode project and deploy to iOS Simulator.

## Workflow

### Step 1: Get Xcode Tab Identifier

```
mcp_xcode_XcodeListWindows
```

Extract `tabIdentifier` from the response (e.g., `windowtab2`).

### Step 2: Build the Project

```
mcp_xcode_BuildProject with tabIdentifier
```

Wait for successful build.

### Step 3: Find the Built App

```bash
find ~/Library/Developer/Xcode/DerivedData -name "AppName.app" -path "*Debug-iphonesimulator*" 2>/dev/null
```

Use the path from `Build/Products/Debug-iphonesimulator/` (NOT `Index.noindex/Build/Products/`).

### Step 4: Find Target Simulator

```bash
xcrun simctl list devices | grep -i "device name"
```

Extract the UUID (e.g., `F574B0CD-C866-483C-BB1B-1B85E2B7BAE0`).

### Step 5: Install and Launch

```bash
xcrun simctl install <SIMULATOR_UUID> "<PATH_TO_APP>"
```

Get bundle identifier from Info.plist if unknown:

```bash
plutil -p "<PATH_TO_APP>/Info.plist" | grep -i bundleidentifier
```

Launch the app:

```bash
xcrun simctl launch <SIMULATOR_UUID> <BUNDLE_ID>
```

## Combined Command

After initial setup, combine install and launch:

```bash
xcrun simctl install <UUID> "<APP_PATH>" && xcrun simctl launch <UUID> <BUNDLE_ID>
```

## Notes

- Always use `mcp_xcode_BuildProject` instead of `xcodebuild` CLI for building
- The correct `.app` path is in `Build/Products/`, not `Index.noindex/Build/Products/`
- Boot simulator first if not already booted: `xcrun simctl boot <UUID>`
