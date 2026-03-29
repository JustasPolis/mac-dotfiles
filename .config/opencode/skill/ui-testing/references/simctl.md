# simctl Reference

## Overview

`xcrun simctl` controls iOS Simulator devices: boot, install apps, configure settings, manage permissions, simulate push notifications, and more.

The special device identifier `booted` targets the currently booted simulator.

## Device Management

### List Devices

```bash
# All devices
xcrun simctl list devices

# Only available (installed runtimes)
xcrun simctl list devices available

# Filter by name
xcrun simctl list devices | grep "iPhone"

# JSON output
xcrun simctl list devices -j
```

### Boot / Shutdown

```bash
xcrun simctl boot <UDID>
xcrun simctl shutdown <UDID>
xcrun simctl shutdown all
```

### Create / Delete

```bash
# Create a device
xcrun simctl create "TestDevice" "iPhone 16" "iOS18.2"

# Delete
xcrun simctl delete <UDID>
xcrun simctl delete unavailable  # Remove devices with missing runtimes
```

### Erase (Reset to Clean State)

```bash
xcrun simctl erase <UDID>
xcrun simctl erase all
```

## App Management

### Install / Uninstall

```bash
xcrun simctl install booted /path/to/App.app
xcrun simctl uninstall booted com.example.app
```

### Launch / Terminate

```bash
xcrun simctl launch booted com.example.app
xcrun simctl launch --console booted com.example.app  # Show stdout/stderr
xcrun simctl terminate booted com.example.app
```

### App Info

```bash
xcrun simctl appinfo booted com.example.app
xcrun simctl listapps booted
xcrun simctl get_app_container booted com.example.app
xcrun simctl get_app_container booted com.example.app data  # Data container
```

## Deep Links / URLs

```bash
xcrun simctl openurl booted "myapp://path/to/screen"
xcrun simctl openurl booted "https://example.com/deeplink"
```

## Push Notifications

```bash
# From file
xcrun simctl push booted com.example.app payload.json

# From stdin
echo '{"aps":{"alert":"Test notification","sound":"default"}}' | xcrun simctl push booted com.example.app -
```

Example payload file:
```json
{
  "Simulator Target Bundle": "com.example.app",
  "aps": {
    "alert": {
      "title": "Test",
      "body": "This is a test notification"
    },
    "sound": "default",
    "badge": 1
  }
}
```

## Privacy / Permissions

Grant permissions without system prompts:

```bash
# Grant specific permission
xcrun simctl privacy booted grant photos com.example.app
xcrun simctl privacy booted grant location com.example.app
xcrun simctl privacy booted grant microphone com.example.app
xcrun simctl privacy booted grant contacts com.example.app
xcrun simctl privacy booted grant calendar com.example.app
xcrun simctl privacy booted grant location-always com.example.app

# Revoke
xcrun simctl privacy booted revoke photos com.example.app

# Reset (will prompt again)
xcrun simctl privacy booted reset all com.example.app
xcrun simctl privacy booted reset all  # All apps
```

Available services: `all`, `calendar`, `contacts-limited`, `contacts`, `location`, `location-always`, `photos-add`, `photos`, `media-library`, `microphone`, `motion`, `reminders`, `siri`.

## Location Simulation

```bash
# Set location (latitude, longitude)
xcrun simctl location booted set 55.6761,12.5683  # Copenhagen

# Clear simulated location
xcrun simctl location booted clear
```

## Screenshots and Video

```bash
# Screenshot
xcrun simctl io booted screenshot screenshot.png
xcrun simctl io booted screenshot --type=jpeg screenshot.jpg

# Record video
xcrun simctl io booted recordVideo recording.mov
# Press Ctrl+C to stop recording

# Record with codec
xcrun simctl io booted recordVideo --codec=h264 recording.mov
```

## Pasteboard

```bash
# Copy text to simulator pasteboard
echo "text to paste" | xcrun simctl pbcopy booted

# Read simulator pasteboard
xcrun simctl pbpaste booted
```

## Keychain

```bash
# Add root certificate (for mitmproxy)
xcrun simctl keychain booted add-root-cert /path/to/cert.pem
```

## Media

```bash
# Add photos/videos to simulator library
xcrun simctl addmedia booted photo.jpg
xcrun simctl addmedia booted video.mp4
```

## Environment Variables

```bash
# Read environment variable from running simulator
xcrun simctl getenv booted HOME
```

## Status Bar Override (iOS 13+)

```bash
# Override status bar for clean screenshots
xcrun simctl status_bar booted override \
  --time "9:41" \
  --batteryState charged \
  --batteryLevel 100 \
  --wifiBars 3 \
  --cellularBars 4

# Clear overrides
xcrun simctl status_bar booted clear
```
