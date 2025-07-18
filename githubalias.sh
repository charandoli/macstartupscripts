#!/bin/bash

# Git Aliases Script
#
# This script configures a set of useful Git aliases in your global .gitconfig file.
# To use it, save the file as `setup_git_aliases.sh`, give it execute permissions
# with `chmod +x setup_git_aliases.sh`, and then run it with `./setup_git_aliases.sh`.

echo "Setting up Git aliases..."

# --- Status ---
# 's' for a concise status output
git config --global alias.s 'status -s'

# --- Staging & Committing ---
# 'a' to add all changes to the staging area
git config --global alias.a 'add .'
# 'c' for commit
git config --global alias.c 'commit'
# 'cm' for commit with a message
git config --global alias.cm 'commit -m'
# 'ca' to add all changes and commit
git config --global alias.ca 'commit -a'
# 'cam' to add all changes and commit with a message
git config --global alias.cam 'commit -a -m'
# 'amend' to add to the last commit without changing the commit message
git config --global alias.amend 'commit --amend --no-edit'

# --- Branching ---
# 'b' for branch
git config --global alias.b 'branch'
# 'ba' to list all branches (local and remote)
git config --global alias.ba 'branch -a'
# 'bd' to delete a local branch
git config --global alias.bd 'branch -d'
# 'bD' to forcefully delete a local branch
git config --global alias.bD 'branch -D'

# --- Checkout ---
# 'co' for checkout
git config --global alias.co 'checkout'
# 'cb' to create a new branch and switch to it
git config --global alias.cb 'checkout -b'
# 'cob' is an alternative for creating a new branch
git config --global alias.cob 'checkout -b'

# --- Logging & History ---
# 'l' for a detailed, one-line log
git config --global alias.l "log --oneline --decorate --graph --all"
# 'll' for a more detailed log with stats
git config --global alias.ll "log --pretty=format:'%C(yellow)%h %ad%C(reset) | %s%C(red)%d%C(reset) [%C(green)%an%C(reset)]' --date=short"
# 'lg' for a beautiful graph log
git config --global alias.lg "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
# 'hist' for a classic history view
git config --global alias.hist "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"

# --- Remotes & Fetching ---
# 'f' for fetch
git config --global alias.f 'fetch'
# 'p' for pull
git config --global alias.p 'pull'
# 'ps' for push
git config --global alias.ps 'push'
# 'pf' to force push (use with caution!)
git config --global alias.pf 'push --force-with-lease'

# --- Stashing ---
# 'st' for stash
git config --global alias.st 'stash'
# 'sta' to apply the last stash
git config --global alias.sta 'stash apply'
# 'stp' to pop the last stash
git config --global alias.stp 'stash pop'
# 'stl' to list all stashes
git config --global alias.stl 'stash list'

# --- Diffs ---
# 'd' for diff
git config --global alias.d 'diff'
# 'dc' for a cached diff (shows staged changes)
git config --global alias.dc 'diff --cached'

# --- Resetting ---
# 'unstage' to unstage a file
git config --global alias.unstage 'reset HEAD --'
# 'rh' to reset hard to HEAD (discards all local changes)
git config --global alias.rh 'reset --hard'
# 'r1' to reset to the previous commit
git config --global alias.r1 'reset HEAD~1'

# --- Show ---
# 'sh' to show details of a commit
git config --global alias.sh 'show'

echo "Git aliases have been set. You can view them with 'git config --global -l | grep alias'."
echo "Restart your terminal for all aliases to be available."

