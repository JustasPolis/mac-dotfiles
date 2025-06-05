set fish_greeting ""
eval "$(/opt/homebrew/bin/brew shellenv)"
starship init fish | source
set fzf_fd_opts --hidden --max-depth 3
set EDITOR nvim

zoxide init --cmd cd fish | source
set -x PATH $PATH ~/.cargo/bin
set -gx PATH /opt/homebrew/bin $PATH

set -x PATH /Users/justinpolis/Library/Android/sdk/build-tools/35.0.0 $PATH
set -x PATH "$PATH:$(go env GOPATH)/bin"


alias tcs="sesh connect (sesh list -i | gum filter --limit 1 --placeholder 'Pick session' --height 20 --prompt='⚡')"
alias tksession="tmux kill-session"
alias tkserver="tmux kill-server"
alias tkw="tmux kill-window"
alias td="tmux detach"


# set fish_color_valid_path
# set fish_color_redirection cyan
# set fish_color_autosuggestion 'brblack'
# set fish_color_history_current 'brblack'
# set fish_pager_color_prefix normal
# set fish_color_selection 'white' '--background=yellow'
# set fish_color_error red
# set fish_color_escape cyan
# set fish_color_operator cyan
# set fish_color_search_match 'yellow' '--background=black' 
# set fish_color_user green
# set fish_pager_color_description yellow
#set fish_pager_color_progress 'white' '--background=cyan'
fish_vi_cursor --force-iterm
set -g fish_cursor_insert line
set -g fish_cursor_default block

bind -M default \cz 'fg 2>/dev/null; commandline -f repaint'
bind -M insert \cz 'fg 2>/dev/null; commandline -f repaint'

# set fish_color_valid_path
# set fish_color_redirection cyan
# set fish_color_history_current
# set fish_pager_color_prefix normal
# set fish_color_selection white

set -Ux FZF_DEFAULT_OPTS "\
--ansi \
--border none \
--color='16,bg+:-1,gutter:-1,prompt:5,pointer:5,marker:6,border:4,label:4,header:italic' \
--marker=' ' \
--no-info \
--no-separator \
--reverse"

set -Ux FZF_TMUX_OPTS "-p 55%,60%"

set -Ux FZF_CTRL_R_OPTS "\
--border-label=' history ' \
--prompt='  '"

#if test -f /opt/homebrew/anaconda3/bin/conda
#    eval /opt/homebrew/anaconda3/bin/conda "shell.fish" "hook" $argv | source
#else
#    if test -f "/opt/homebrew/anaconda3/etc/fish/conf.d/conda.fish"
#        . "/opt/homebrew/anaconda3/etc/fish/conf.d/conda.fish"
#    else
#        set -x PATH "/opt/homebrew/anaconda3/bin" $PATH
#    end
#end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
#source ~/.orbstack/shell/init2.fish 2>/dev/null || :

set -g fish_color_normal normal
set -g fish_color_command normal
set -g fish_color_keyword normal
set -g fish_color_quote normal
set -g fish_color_redirection normal
set -g fish_color_end normal
set -g fish_color_error normal
set -g fish_color_param normal
set -g fish_color_comment normal
set -g fish_color_match normal
set -g fish_color_search_match normal
set -g fish_color_operator normal
set -g fish_color_selection yellow

set -g fish_pager_color_progress normal
set -g fish_pager_color_background normal
set -g fish_pager_color_prefix normal
set -g fish_pager_color_completion normal
set -g fish_pager_color_description normal
set -g fish_pager_color_selected_background --background=44475a
set -g fish_pager_color_selected_prefix normal
set -g fish_pager_color_selected_completion normal
set -g fish_pager_color_selected_description normal
set -g fish_pager_color_secondary_background
set -g fish_pager_color_secondary_prefix normal
set -g fish_pager_color_secondary_completion normal
set -g fish_pager_color_secondary_description normal

set -e LSCOLORS
set -e LS_COLORS
set -x CLICOLOR 0
alias ls='ls --color=never'

# Disable color for grep
alias grep='grep --color=never'

# Disable color for git
set -x GIT_CONFIG_PARAMETERS "'color.ui=never'"

# Disable color for Homebrew
set -x HOMEBREW_NO_COLOR 1

set -x FZF_DEFAULT_OPTS "--no-color"
