set fish_greeting ""
eval "$(/opt/homebrew/bin/brew shellenv)"
starship init fish | source
set EDITOR nvim
zoxide init --cmd cd fish | source
set -x PATH $PATH ~/.cargo/bin
set -gx PATH /opt/homebrew/bin $PATH
set -x PATH "$PATH:$(go env GOPATH)/bin"

fish_vi_cursor --force-iterm
set -g fish_cursor_insert line
set -g fish_cursor_default block

bind -M default \cz 'fg 2>/dev/null; commandline -f repaint'
bind -M insert \cz 'fg 2>/dev/null; commandline -f repaint'

function fish_user_key_bindings
    bind \cf forward-char
    bind \cb backward-char
end

fish_vi_key_bindings

set -g nvim_dark_blue     004c63
set -g nvim_dark_cyan     007373
set -g nvim_dark_green    005523
set -g nvim_dark_magenta  470045
set -g nvim_dark_red      590008
set -g nvim_dark_yellow   6b5300
set -g nvim_light_blue    A6DBFF
set -g nvim_light_cyan    8cf8f7
set -g nvim_light_green   b4f6c0
set -g nvim_light_magenta FFCAFF
set -g nvim_light_red     FFC0B9
set -g nvim_light_yellow  FCE094
set -g nvim_light_grey1   EEF1F8
set -g nvim_light_grey2   E0E2EA
set -g nvim_light_grey3   C4C6CD
set -g nvim_light_grey4   9b9ea4
set -g nvim_dark_grey4    4f5258
set -g nvim_dark_grey3    2c2e33
set -g nvim_dark_grey2    14161B
set -g nvim_dark_grey1    07080D

set -U fish_color_normal           $nvim_light_grey3
set -U fish_color_command          $nvim_light_cyan
set -U fish_color_keyword          $nvim_light_cyan
set -U fish_color_quote            $nvim_light_magenta
set -U fish_color_redirection      $nvim_dark_cyan
set -U fish_color_end              $nvim_light_cyan
set -U fish_color_error            $nvim_light_red
set -U fish_color_param            $nvim_light_green
set -U fish_color_option           $nvim_light_yellow
set -U fish_color_comment          $nvim_dark_grey4
set -U fish_color_operator         $nvim_light_yellow
set -U fish_color_escape           $nvim_light_cyan
set -U fish_color_autosuggestion   $nvim_dark_grey4
set -U fish_color_cwd              $nvim_light_green
set -U fish_color_cwd_root         $nvim_light_red
set -U fish_color_valid_path       $nvim_light_blue
set -U fish_color_selection        --background=$nvim_dark_yellow
set -U fish_color_search_match     $nvim_dark_grey1 --bold --background=$nvim_light_yellow
set -U fish_pager_color_prefix                 $nvim_light_cyan --bold
set -U fish_pager_color_completion             $nvim_light_grey3
set -U fish_pager_color_description            $nvim_light_grey4
set -U fish_pager_color_progress               $nvim_light_blue --bold
set -U fish_pager_color_secondary_description  $nvim_dark_grey4
set -U fish_pager_color_selected_background    --background=$nvim_dark_grey3
set -U fish_pager_color_selected_prefix        $nvim_light_cyan --bold
set -U fish_pager_color_selected_completion    $nvim_light_grey1
set -U fish_pager_color_selected_description   $nvim_light_grey4
bind -M insert \cf forward-char
set -x STARSHIP_VIMCMD false
