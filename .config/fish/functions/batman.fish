function batman
    # Check if an argument was provided
    if count $argv > /dev/null
        # -c "only" closes the empty buffer that usually opens alongside the man page
        nvim -c "Man $argv" -c "only"
    else
        echo "Usage: batman <manpage>"
    end
end
