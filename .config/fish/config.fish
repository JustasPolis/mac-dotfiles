set fish_greeting ""
set -x FZF_DEFAULT_OPTS '--no-sort --ansi --header "" --no-info --preview-window hidden --bind "tab:down,btab:up"'
set -gx TERMINFO_DIRS "$TERMINFO_DIRS:/opt/homebrew/share/terminfo"
eval "$(/opt/homebrew/bin/brew shellenv)"
starship init fish | source
set EDITOR nvim
zoxide init --cmd cd fish | source
set -x PATH $PATH ~/.cargo/bin
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /Users/justaspolikevicius/job/depot_tools $PATH
set -gx PATH ~/.local/share/bob/nvim-bin $PATH
set -gx GOOGLE_CLOUD_PROJECT "nimble-radio-231516"
set -gx OPENCODE_GEMINI_PROJECT_ID "nimble-radio-231516"
set -gx OPENCODE_EXPERIMENTAL_LSP_TOOL true
test -f ~/.config/fish/secrets.fish && source ~/.config/fish/secrets.fish
set -gx NO_UPDATE_NOTIFIER 1

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

set -g nvim_light_blue    A6DBFF 
set -g nvim_light_cyan    A6DBFF 
set -g nvim_light_green   a1c5bc 
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
set -U fish_color_command          $nvim_light_green
set -U fish_color_keyword          $nvim_light_cyan
set -U fish_color_quote            $nvim_light_magenta
set -U fish_color_redirection      $nvim_light_cyan
set -U fish_color_end              $nvim_light_cyan
set -U fish_color_error            $nvim_light_green
set -U fish_color_param            $nvim_light_green
set -U fish_color_option           $nvim_light_yellow
set -U fish_color_comment          $nvim_light_grey3
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

abbr -a gs git status
abbr -a ga git add
abbr -a gai git add -i
abbr -a gcm git commit
abbr -a gch git checkout 
abbr -a gp git push
abbr -a gl git log
abbr -a oc opencode
abbr -a ss seshstart

set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

