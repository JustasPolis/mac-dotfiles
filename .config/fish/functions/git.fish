function git --wraps git
    if test "$argv[1]" = "add"; and contains -- -i $argv
        command git diff --name-only | fzf -m | xargs command git add
    else if test "$argv[1]" = diff
        if not command git diff --exit-code $argv[2..] >/dev/null
            command nvim -c "Diff $argv[2..]"
        end
    else
        command git $argv
    end
end
