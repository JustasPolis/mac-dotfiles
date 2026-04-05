function rm --wraps rm
    if contains -- -i $argv
        set -l args (string match -v -- '-i' $argv)
        ls | fzf -m | xargs command rm $args
    else
        command rm $argv
    end
end
