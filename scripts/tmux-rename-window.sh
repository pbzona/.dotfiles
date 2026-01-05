#!/usr/bin/env bash

# If an argument is provided, use it directly
if [[ -n "$1" ]]; then
    tmux rename-window "$1"
    exit 0
fi

# Otherwise, auto-detect the name
# Get the current directory
current_dir=$(pwd)

# Check if we're in a git repository
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Get the remote URL
    remote_url=$(git remote get-url origin 2>/dev/null)
    
    if [[ -n "$remote_url" ]]; then
        # Extract owner/repo from various URL formats
        # Handles: git@github.com:owner/repo.git
        #          https://github.com/owner/repo.git
        #          https://github.com/owner/repo
        if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
            owner="${BASH_REMATCH[1]}"
            repo="${BASH_REMATCH[2]}"
            window_name="${owner}/${repo}"
        elif [[ "$remote_url" =~ [:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
            # Generic pattern for other Git hosts
            owner="${BASH_REMATCH[1]}"
            repo="${BASH_REMATCH[2]}"
            window_name="${owner}/${repo}"
        else
            # Fallback to directory name if URL doesn't match expected pattern
            window_name=$(basename "$current_dir")
        fi
    else
        # No remote, use directory name
        window_name=$(basename "$current_dir")
    fi
else
    # Not a git repo, use directory name
    window_name=$(basename "$current_dir")
fi

# Rename the tmux window
tmux rename-window "$window_name"
