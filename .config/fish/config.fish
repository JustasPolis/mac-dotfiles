set fish_greeting ""
set -x FZF_DEFAULT_OPTS '--no-sort --ansi --header "" --no-info --preview-window hidden --bind "tab:down,btab:up" --color=fg:#c9c7cd,bg:#161617,hl:#c9a5b5,fg+:#c9c7cd,bg+:#353539,hl+:#c9a5b5,info:#7b7b80,prompt:#bdb2e0,pointer:#c9a5b5,marker:#d4b5a0,spinner:#bdb2e0,header:#7b7b80,scrollbar:#353539,border:#353539'
set -gx TERMINFO_DIRS "$TERMINFO_DIRS:/opt/homebrew/share/terminfo"
eval "$(/opt/homebrew/bin/brew shellenv)"
starship init fish | source
set EDITOR nvim
zoxide init --cmd cd fish | source
set -x PATH $PATH ~/.cargo/bin
set -gx PATH /opt/homebrew/bin $PATH
set -gx LS_COLORS (vivid generate mellow)
set -gx PATH /Users/justaspolikevicius/job/depot_tools $PATH
set -gx PATH ~/.local/share/bob/nvim-bin $PATH
set -gx GOOGLE_CLOUD_PROJECT "nimble-radio-231516"
set -gx OPENCODE_GEMINI_PROJECT_ID "nimble-radio-231516"
set -gx OPENCODE_EXPERIMENTAL_LSP_TOOL true
test -f ~/.config/fish/secrets.fish && source ~/.config/fish/secrets.fish
set -gx NO_UPDATE_NOTIFIER 1
set -gx GITLAB_AUTH_TOKEN (security find-generic-password -s gitlab.com -w 2>/dev/null)

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
fzf --fish | source

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

