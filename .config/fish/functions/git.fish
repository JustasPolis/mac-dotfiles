function git --wraps git
    if test "$argv[1]" = "add"; and contains -- -i $argv
        command git diff --name-only | fzf -m | xargs command git add
    else
        command git $argv
    end
end
