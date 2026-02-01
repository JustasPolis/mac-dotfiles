function seshstart
    set -l selected (sesh list --icons | fzf-tmux -p 55%,60%)
    
    if test -n "$selected"
        sesh connect "$selected"
    end
end
