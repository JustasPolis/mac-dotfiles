# axe CLI Reference

`axe` interacts with iOS Simulators via accessibility APIs. All commands require `--udid <UDID>`.

## Get UDID

```bash
axe list-simulators
xcrun simctl list devices | grep Booted
```

## describe-ui

Read the accessibility tree of the current screen. **Always call before interacting.**

```bash
axe describe-ui --udid <UDID>
```

Returns: `AXUniqueId` (use with `--id`), `AXLabel` (use with `--label`), positions, sizes, types.

## tap

```bash
axe tap --id "login_button" --udid <UDID>              # By identifier (most reliable)
axe tap --label "Sign In" --udid <UDID>                # By label
axe tap -x 200 -y 400 --udid <UDID>                   # By coordinates
axe tap --id "btn" --pre-delay 0.5 --post-delay 1.0 --udid <UDID>  # With delays
```

If `-x`/`-y` provided, they override `--id`/`--label`.

## type

```bash
axe type "Hello World" --udid <UDID>                   # Direct text
echo "text" | axe type --stdin --udid <UDID>           # From stdin
axe type --file input.txt --udid <UDID>                # From file
```

Only US keyboard characters. Tap a text field first, then type.

## swipe

```bash
axe swipe --start-x 200 --start-y 600 --end-x 200 --end-y 200 --udid <UDID>
axe swipe --start-x 200 --start-y 600 --end-x 200 --end-y 200 --duration 1.5 --udid <UDID>
```

## gesture (preset patterns)

```bash
axe gesture scroll-up --udid <UDID>
axe gesture scroll-down --udid <UDID>
axe gesture scroll-left --udid <UDID>
axe gesture scroll-right --udid <UDID>
axe gesture swipe-from-left-edge --udid <UDID>     # Back navigation
axe gesture swipe-from-right-edge --udid <UDID>
axe gesture swipe-from-top-edge --udid <UDID>      # Notification center
axe gesture swipe-from-bottom-edge --udid <UDID>   # Home indicator
axe gesture scroll-down --screen-width 430 --screen-height 932 --udid <UDID>
axe gesture scroll-down --pre-delay 0.5 --post-delay 1.0 --udid <UDID>
```

## button (hardware)

```bash
axe button home --udid <UDID>
axe button lock --udid <UDID>
axe button siri --udid <UDID>
axe button side-button --udid <UDID>
axe button apple-pay --udid <UDID>
axe button lock --duration 2.0 --udid <UDID>       # Long press
```

## key (HID keycode)

```bash
axe key 40 --udid <UDID>    # Return/Enter
axe key 42 --udid <UDID>    # Backspace
axe key 43 --udid <UDID>    # Tab
axe key 44 --udid <UDID>    # Space
axe key 42 --duration 1.0 --udid <UDID>  # Hold backspace
```

## key-combo

```bash
axe key-combo --modifiers 227 --key 4 --udid <UDID>       # Cmd+A (Select All)
axe key-combo --modifiers 227 --key 6 --udid <UDID>       # Cmd+C (Copy)
axe key-combo --modifiers 227 --key 25 --udid <UDID>      # Cmd+V (Paste)
axe key-combo --modifiers 227,225 --key 4 --udid <UDID>   # Cmd+Shift+A
```

Modifiers: 224=LCtrl, 225=LShift, 226=LAlt, 227=LCmd, 228=RCtrl, 229=RShift, 230=RAlt, 231=RCmd

## touch (low-level)

```bash
axe touch --x 100 --y 200 --down --up --udid <UDID>               # Tap
axe touch --x 100 --y 200 --down --up --delay 1.0 --udid <UDID>   # Long press
axe touch --x 100 --y 200 --down --udid <UDID>                    # Drag start
axe touch --x 300 --y 400 --up --udid <UDID>                      # Drag end
```

## Common Patterns

### Tap and Type
```bash
axe tap --id "email_field" --udid $UDID
axe type "user@example.com" --udid $UDID
```

### Clear Text Field
```bash
axe tap --id "text_field" --udid $UDID
axe key-combo --modifiers 227 --key 4 --udid $UDID   # Cmd+A
axe key 42 --udid $UDID                               # Backspace
```

### Dismiss Keyboard
```bash
axe key 40 --udid $UDID  # Return
```
