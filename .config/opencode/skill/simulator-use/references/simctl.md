# simctl Reference

`xcrun simctl` controls iOS Simulator devices. The special identifier `booted` targets the currently booted simulator.

## Device Management

```bash
xcrun simctl list devices                          # All devices
xcrun simctl list devices available                # Only installed runtimes
xcrun simctl list devices available | grep iPhone  # Filter iPhones
xcrun simctl list devices -j                       # JSON output
xcrun simctl boot <UDID>                           # Boot
xcrun simctl shutdown <UDID>                       # Shutdown
xcrun simctl shutdown all                          # Shutdown all
xcrun simctl create "Name" "iPhone 16" "iOS18.2"   # Create
xcrun simctl delete <UDID>                         # Delete
xcrun simctl delete unavailable                    # Delete devices with missing runtimes
xcrun simctl erase <UDID>                          # Reset to clean state
```

## App Management

```bash
xcrun simctl install booted /path/to/App.app
xcrun simctl uninstall booted com.example.app
xcrun simctl launch booted com.example.app
xcrun simctl launch --console booted com.example.app   # Show stdout/stderr
xcrun simctl terminate booted com.example.app
xcrun simctl appinfo booted com.example.app
xcrun simctl listapps booted
xcrun simctl get_app_container booted com.example.app
xcrun simctl get_app_container booted com.example.app data  # Data container
```

## Deep Links

```bash
xcrun simctl openurl booted "myapp://path/to/screen"
xcrun simctl openurl booted "https://example.com/deeplink"
```

## Push Notifications

```bash
xcrun simctl push booted com.example.app payload.json
echo '{"aps":{"alert":"Test","sound":"default"}}' | xcrun simctl push booted com.example.app -
```

Payload example:
```json
{
  "Simulator Target Bundle": "com.example.app",
  "aps": {
    "alert": {"title": "Test", "body": "Notification body"},
    "sound": "default",
    "badge": 1
  }
}
```

## Permissions

```bash
xcrun simctl privacy booted grant <service> <BUNDLE_ID>
xcrun simctl privacy booted revoke <service> <BUNDLE_ID>
xcrun simctl privacy booted reset all <BUNDLE_ID>
```

Services: `all`, `calendar`, `contacts-limited`, `contacts`, `location`, `location-always`, `photos-add`, `photos`, `media-library`, `microphone`, `motion`, `reminders`, `siri`.

## Location

```bash
xcrun simctl location booted set 55.6761,12.5683   # Copenhagen
xcrun simctl location booted clear
```

## Screenshots & Video

```bash
xcrun simctl io booted screenshot screenshot.png
xcrun simctl io booted screenshot --type=jpeg screenshot.jpg
xcrun simctl io booted recordVideo recording.mov       # Ctrl+C to stop
xcrun simctl io booted recordVideo --codec=h264 recording.mov
```

## Pasteboard

```bash
echo "text" | xcrun simctl pbcopy booted
xcrun simctl pbpaste booted
```

## Keychain

```bash
xcrun simctl keychain booted add-root-cert /path/to/cert.pem
```

## Media

```bash
xcrun simctl addmedia booted photo.jpg
xcrun simctl addmedia booted video.mp4
```

## Status Bar Override

```bash
xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4
xcrun simctl status_bar booted clear
```
