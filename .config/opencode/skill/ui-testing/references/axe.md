# axe CLI Reference

## Overview

`axe` interacts with iOS Simulators via accessibility APIs. It reads UI hierarchy, taps elements, types text, performs gestures, and presses hardware buttons. All commands require `--udid <SIMULATOR_UDID>`.

## Get Simulator UDID

```bash
# List all simulators
axe list-simulators

# Or via simctl (filter booted)
xcrun simctl list devices | grep Booted
```

## Commands

### describe-ui

Read the full accessibility tree of the current screen. Use this to understand what's on screen before interacting.

```bash
axe describe-ui --udid <UDID>
```

Returns a hierarchy of accessibility elements with:
- `AXUniqueId` (accessibilityIdentifier) - use with `--id` for taps
- `AXLabel` (accessibilityLabel) - use with `--label` for taps
- Element positions and sizes
- Element types and traits

**Always call `describe-ui` first** to discover element identifiers before tapping.

### tap

Tap an element by accessibility identifier, label, or coordinates.

```bash
# By accessibilityIdentifier (most reliable)
axe tap --id "login_button" --udid <UDID>

# By accessibilityLabel
axe tap --label "Sign In" --udid <UDID>

# By exact coordinates
axe tap -x 200 -y 400 --udid <UDID>

# With delays (useful for animations)
axe tap --id "button" --pre-delay 0.5 --post-delay 1.0 --udid <UDID>
```

**Priority**: If `-x` and `-y` are provided, they override `--id`/`--label`.

### type

Type text into the focused input field.

```bash
# Direct text
axe type "Hello World" --udid <UDID>

# From stdin (good for special characters)
echo "complex text" | axe type --stdin --udid <UDID>

# From file
axe type --file input.txt --udid <UDID>
```

**Limitations**: Only US keyboard characters (A-Z, a-z, 0-9, common symbols). No international characters.

**Tip**: Tap a text field first with `axe tap`, then use `axe type`.

### swipe

Perform a swipe gesture between two points.

```bash
# Swipe up (scroll down)
axe swipe --start-x 200 --start-y 600 --end-x 200 --end-y 200 --udid <UDID>

# Slow swipe
axe swipe --start-x 200 --start-y 600 --end-x 200 --end-y 200 --duration 1.5 --udid <UDID>
```

### gesture

Perform preset gesture patterns (easier than manual swipe coordinates).

```bash
# Scroll
axe gesture scroll-up --udid <UDID>
axe gesture scroll-down --udid <UDID>
axe gesture scroll-left --udid <UDID>
axe gesture scroll-right --udid <UDID>

# Edge swipes (navigation)
axe gesture swipe-from-left-edge --udid <UDID>    # Back navigation
axe gesture swipe-from-right-edge --udid <UDID>
axe gesture swipe-from-top-edge --udid <UDID>     # Notification center
axe gesture swipe-from-bottom-edge --udid <UDID>  # Home indicator

# With custom screen dimensions
axe gesture scroll-down --screen-width 430 --screen-height 932 --udid <UDID>

# With delays
axe gesture scroll-down --pre-delay 0.5 --post-delay 1.0 --udid <UDID>
```

### button

Press hardware buttons.

```bash
axe button home --udid <UDID>
axe button lock --udid <UDID>
axe button siri --udid <UDID>
axe button side-button --udid <UDID>
axe button apple-pay --udid <UDID>

# Long press
axe button lock --duration 2.0 --udid <UDID>
```

### key

Press a single key by HID keycode.

```bash
axe key 40 --udid <UDID>   # Return/Enter
axe key 42 --udid <UDID>   # Backspace
axe key 43 --udid <UDID>   # Tab
axe key 44 --udid <UDID>   # Space

# Hold key
axe key 42 --duration 1.0 --udid <UDID>  # Hold Backspace for 1s
```

### key-combo

Press a key with modifier keys held.

```bash
# Cmd+A (Select All) - modifier 227 = Left Command, key 4 = A
axe key-combo --modifiers 227 --key 4 --udid <UDID>

# Cmd+C (Copy)
axe key-combo --modifiers 227 --key 6 --udid <UDID>

# Cmd+V (Paste)
axe key-combo --modifiers 227 --key 25 --udid <UDID>

# Cmd+Shift+A
axe key-combo --modifiers 227,225 --key 4 --udid <UDID>
```

**Modifier keycodes**: 224=LCtrl, 225=LShift, 226=LAlt, 227=LCmd, 228=RCtrl, 229=RShift, 230=RAlt, 231=RCmd

### touch

Low-level touch events for advanced control.

```bash
# Touch down then up (like a tap)
axe touch --x 100 --y 200 --down --up --udid <UDID>

# Long press (hold 1 second)
axe touch --x 100 --y 200 --down --up --delay 1.0 --udid <UDID>

# Just touch down (for drag start)
axe touch --x 100 --y 200 --down --udid <UDID>

# Just touch up (for drag end)
axe touch --x 300 --y 400 --up --udid <UDID>
```

### stream-video

Stream simulator screen frames.

```bash
# Default MJPEG stream at 10fps
axe stream-video --udid <UDID>

# Lower quality for faster streaming
axe stream-video --udid <UDID> --fps 5 --quality 50 --scale 0.5

# Different formats
axe stream-video --udid <UDID> --format raw
axe stream-video --udid <UDID> --format ffmpeg
```

## Common Interaction Patterns

### Tap and Type

```bash
UDID="<simulator-udid>"
axe tap --id "email_field" --udid $UDID
axe type "user@example.com" --udid $UDID
axe tap --id "password_field" --udid $UDID
axe type "password123" --udid $UDID
axe tap --id "login_button" --udid $UDID
```

### Scroll Until Element Visible

Use `describe-ui` between scroll gestures to check if the target element has appeared.

### Clear Text Field

```bash
# Select all then delete
axe tap --id "text_field" --udid $UDID
axe key-combo --modifiers 227 --key 4 --udid $UDID   # Cmd+A
axe key 42 --udid $UDID                                # Backspace
```

### Dismiss Keyboard

```bash
axe key 40 --udid $UDID  # Press Return
# or tap outside the text field
```
