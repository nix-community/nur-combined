% WUT(1) wut 0.1.2
% Kieran Klukas
% January 2026

# NAME

wut - Worktrees Unexpectedly Tolerable - ephemeral Git worktrees without the ceremony

# SYNOPSIS

**wut** **new** *BRANCH* [**--from** *REF*]

**wut** **list**

**wut** **go** [*BRANCH*]

**wut** **path** *BRANCH*

**wut** **rm** *BRANCH* [**--force**]

**wut** **--help** | **-h**

**wut** **--version** | **-V**

# DESCRIPTION

**wut** simplifies Git worktree management for short-lived development sessions. It stores worktrees in a **.worktrees** folder (automatically added to .gitignore) within the repository, providing a streamlined workflow for ephemeral branching.

This is particularly useful for agentic workflows where quick, temporary branches are frequently created and destroyed.

# COMMANDS

**new** *BRANCH* [**--from** *REF*]
: Create a new worktree for the specified branch. If the branch exists locally or on origin, it will be checked out. Otherwise, a new branch is created from HEAD (or the specified ref with **--from**). Automatically changes to the new worktree directory.

**list**
: Display all worktrees with their branch names and paths. Icons indicate:
  - 🏠 Repository root
  - 👉 Current worktree
  - 🌿 Other worktrees

**go** [*BRANCH*]
: Navigate to the specified worktree. If no branch is specified, returns to the repository root.

**path** *BRANCH*
: Print the filesystem path to the worktree for the specified branch. Useful for scripting.

**rm** *BRANCH* [**--force**]
: Remove the worktree and delete the branch. By default, refuses to remove worktrees with uncommitted changes or unmerged branches. Use **--force** to override safety checks and remove anyway. If currently inside the worktree being removed, automatically returns to the repository root.

# OPTIONS

**-h**, **--help**
: Show help message and exit.

**-V**, **--version**
: Show version number and exit.

**--from** *REF*
: (For **new** command) Create the new branch from the specified ref instead of HEAD.

**--force**
: (For **rm** command) Force removal even if the worktree has uncommitted changes or the branch is not fully merged.

# WORKTREE STORAGE

All worktrees are stored in **.worktrees/** at the repository root. This directory is automatically added to **.gitignore** when you first create a worktree.

Branch names containing slashes (e.g., **feature/foo**) are converted to use hyphens (e.g., **feature-foo**) for the directory name.

# SHELL INTEGRATION

**wut** requires shell integration for commands that change directories (**new**, **go**, **rm --force**). This is automatically configured when using the home-manager module with **atelier.shell.wut.enable = true**.

The shell wrapper intercepts special **__WUT_CD__** markers from the command output to perform directory changes in the parent shell.

# EXAMPLES

Create a new worktree for a feature branch:
```
$ wut new feature/add-login
```

Create a worktree from a specific commit:
```
$ wut new hotfix/urgent --from v1.0.0
```

List all worktrees:
```
$ wut list
🏠 main        ~/projects/myapp
👉 feature-x   ~/projects/myapp/.worktrees/feature-x
🌿 bugfix-y    ~/projects/myapp/.worktrees/bugfix-y
```

Switch to a different worktree:
```
$ wut go bugfix-y
```

Return to the main repository:
```
$ wut go
```

Get the path to a worktree (for scripting):
```
$ wut path feature-x
/home/user/projects/myapp/.worktrees/feature-x
```

Remove a worktree after merging:
```
$ wut rm feature-x
```

Force remove a worktree with uncommitted changes:
```
$ wut rm abandoned-experiment --force
```

# FILES

**.worktrees/**
: Directory containing all ephemeral worktrees (at repository root)

**.gitignore**
: Automatically updated to ignore the .worktrees directory

# SEE ALSO

git-worktree(1)

Original implementation: https://github.com/simonbs/wut

# AUTHORS

Shell reimplementation by Kieran Klukas, based on wut by Simon B. Støvring.
