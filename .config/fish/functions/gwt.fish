function gwt --description "Create git worktree and connect via sesh"
    # Check if we're in a git repo
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get worktree name from argument or prompt
    set -l worktree_name $argv[1]
    if test -z "$worktree_name"
        echo "Usage: gwt <worktree-name> [branch-name] [base-branch]"
        return 1
    end

    # Branch name defaults to worktree name if not provided
    set -l branch_name $argv[2]
    if test -z "$branch_name"
        set branch_name $worktree_name
    end

    # Base branch defaults to main if not provided
    set -l base_branch $argv[3]
    if test -z "$base_branch"
        set base_branch main
    end

    # Get the git common dir (works from main repo or any worktree)
    set -l git_common_dir (git rev-parse --git-common-dir)
    
    # Get the parent directory where worktrees should live
    # If bare repo: git_common_dir is the root, use it directly
    # If regular repo: git_common_dir ends in .git, use its parent
    set -l worktrees_root
    if test (basename "$git_common_dir") = ".git"
        set worktrees_root (dirname "$git_common_dir")
    else
        set worktrees_root "$git_common_dir"
    end
    
    # Resolve to absolute path
    set worktrees_root (cd "$worktrees_root" && pwd)
    set -l worktree_path "$worktrees_root/$worktree_name"

    # Check if worktree already exists
    if test -d "$worktree_path"
        echo "Worktree directory already exists: $worktree_path"
        echo "Connecting to existing worktree..."
        sesh connect "$worktree_path"
        return 0
    end

    # Create the worktree
    # Resolve base branch to a ref if needed
    set -l base_ref "$base_branch"
    if git show-ref --verify --quiet "refs/heads/$base_branch"
        set base_ref "$base_branch"
    else if git show-ref --verify --quiet "refs/remotes/origin/$base_branch"
        set base_ref "origin/$base_branch"
    else if not git rev-parse --verify --quiet "$base_branch^{commit}"
        echo "Error: Base branch or commit not found: $base_branch"
        return 1
    end

    echo "Creating worktree at $worktree_path with branch $branch_name..."
    
    # Check if branch exists locally or remotely
    set -l local_exists false
    set -l remote_exists false
    
    if git show-ref --verify --quiet "refs/heads/$branch_name"
        set local_exists true
    end
    if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"
        set remote_exists true
    end
    
    if test "$local_exists" = true
        # Local branch exists, use it directly
        if git worktree add "$worktree_path" "$branch_name"
            echo "Created new worktree with existing local branch '$branch_name'"
        else
            echo "Error: Failed to create worktree with local branch '$branch_name'"
            return 1
        end
    else if test "$remote_exists" = true
        # Remote branch exists, create local tracking branch
        if git worktree add "$worktree_path" -b "$branch_name" "origin/$branch_name"
            echo "Created new worktree with branch '$branch_name' tracking 'origin/$branch_name'"
        else
            echo "Error: Failed to create worktree tracking remote branch 'origin/$branch_name'"
            return 1
        end
    else
        # Branch doesn't exist anywhere, create new branch
        if git worktree add "$worktree_path" -b "$branch_name" "$base_ref"
            echo "Created new worktree with new branch '$branch_name'"
        else
            echo "Error: Failed to create worktree with new branch '$branch_name'"
            return 1
        end
    end

    # Add to zoxide and connect via sesh
    zoxide add "$worktree_path"
    sesh connect "$worktree_path"
end
