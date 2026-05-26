set fish_greeting ""
set -x FZF_DEFAULT_OPTS '--no-sort --ansi --header "" --no-info --preview-window hidden --color=fg:#c9c7cd,bg:#161617,hl:#b3a193,fg+:#c9c7cd,bg+:#353539,hl+:#b3a193,info:#7b7b80,prompt:#968a7c,pointer:#b3a193,marker:#d4b5a0,spinner:#968a7c,header:#7b7b80,scrollbar:#353539,border:#353539'
set -gx TERMINFO_DIRS "$TERMINFO_DIRS:/opt/homebrew/share/terminfo"
eval "$(/opt/homebrew/bin/brew shellenv)"
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_INSECURE_REDIRECT 1
set -gx HOMEBREW_CASK_OPTS --require-sha
starship init fish | source
set EDITOR nvim
set -x PATH $PATH ~/.cargo/bin ~/.local/bin
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
set -gx JIRA_API_TOKEN (security find-generic-password -s JIRA_API_TOKEN -w 2>/dev/null)
set -gx OUTLINE_API_TOKEN (security find-generic-password -s outline-api-token -w 2>/dev/null)

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
abbr -a ss seshstart

function git --wraps git
    if test (count $argv) -ge 1; and test "$argv[1]" = diff
        set -l diff_args $argv[2..-1]
        if contains -- --staged $diff_args; or contains -- --cached $diff_args
            command git diff --quiet $diff_args >/dev/null 2>&1
            set -l diff_status $status
            if test $diff_status -eq 0
                echo "No changes"
                return 0
            else if test $diff_status -gt 1
                return $diff_status
            end
        end
    end

    command git $argv
end

set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

