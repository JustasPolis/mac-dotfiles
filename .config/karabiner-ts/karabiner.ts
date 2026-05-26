import { writeToProfile, rule, map, layer, to$, toSetVar, ifVar } from 'karabiner.ts'

// Sends ⌘⌃⌥⇧+H directly. Neru's daemon listens for this chord (see neru config.toml),
// so we skip the shell-spawn latency of invoking the neru CLI.
const homerow = {
  key_code: 'h' as const,
  modifiers: ['left_command', 'left_control', 'left_option', 'left_shift'] as const,
}

const yabai = (args: string) => to$(`/opt/homebrew/bin/yabai ${args}`)
const space = (n: number) => yabai(`-m space --focus ${n}`)
const sendWin = (n: number) => yabai(`-m window --space ${n} --focus`)
const focusWin = (dir: 'west' | 'south' | 'north' | 'east') =>
  yabai(`-m window --focus ${dir}`)

const digits = [1, 2, 3, 4, 5, 6, 7, 8, 9] as const

const cmdBindings = {
  1: space(1), 2: space(2), 3: space(3),
  4: space(4), 5: space(5), 6: space(6),
  7: space(7), 8: space(8), 9: space(9),
  h: focusWin('west'),
  j: focusWin('south'),
  k: focusWin('north'),
  l: focusWin('east'),
} as const

writeToProfile('Default profile', [
  rule('fn -> left_control').manipulators([
    map('fn').to('left_control'),
  ]),

  rule('ctrl + p/n/f/b -> arrows').manipulators([
    map('p', 'control').to('up_arrow'),
    map('n', 'control').to('down_arrow'),
    map('f', 'control').to('right_arrow'),
    map('b', 'control').to('left_arrow'),
  ]),

  rule('cmd_mode (hold)').manipulators([
    // caps_lock down -> hold mode on; up -> hold mode off (and clear submode).
    map('caps_lock')
      .to(toSetVar('cmd_mode_hold', 1))
      .toAfterKeyUp([
        toSetVar('cmd_mode_hold', 0),
        toSetVar('send_prefix', 0),
        toSetVar('send_mode', 0),
        toSetVar('window_prefix', 0),
      ]),
    // send-to-space submode: s -> m -> <digit>. Listed BEFORE the generic
    // cmd_mode digit handlers so send_mode wins when active.
    ...digits.map(n =>
      map(String(n) as any)
        .condition(ifVar('send_mode', 1))
        .to(sendWin(n))
        .to(toSetVar('send_mode', 0)),
    ),
    // s + m -> arm send_mode
    map('m')
      .condition(ifVar('send_prefix', 1))
      .to(toSetVar('send_prefix', 0))
      .to(toSetVar('send_mode', 1)),
    // s in hold mode -> arm send_prefix
    map('s').condition(ifVar('cmd_mode_hold', 1)).to(toSetVar('send_prefix', 1)),
    // hold mode: chord any number of keys, no auto-exit
    ...Object.entries(cmdBindings).map(([k, ev]) =>
      map(k as any).condition(ifVar('cmd_mode_hold', 1)).to(ev),
    ),
    // hold mode + ';' -> activate Neru hints (release caps_lock to type hints)
    map('semicolon').condition(ifVar('cmd_mode_hold', 1)).to(homerow),
    // window submode: w -> f -> toggle zoom-fullscreen (no new space, unlike native)
    map('f')
      .condition(ifVar('window_prefix', 1))
      .to(yabai('-m window --toggle windowed-fullscreen'))
      .to(toSetVar('window_prefix', 0)),
    map('w').condition(ifVar('cmd_mode_hold', 1)).to(toSetVar('window_prefix', 1)),
  ]),

  rule('Cmd+Space -> open Loungy').manipulators([
    map('spacebar', 'command').to$('open /Applications/Loungy.app'),
  ]),

  rule('Disable Cmd+Tab').manipulators([
    map('tab', 'command').to('vk_none'),
  ]),
])
