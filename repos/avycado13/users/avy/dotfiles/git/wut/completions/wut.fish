# fish completion for wut

# Helper function to get worktree branches
function __wut_branches
    git worktree list --porcelain 2>/dev/null | awk '/^branch / { b = substr($0, 8); gsub(/^refs\/heads\//, "", b); print b }'
end

# Disable file completion by default
complete -c wut -f

# Commands
complete -c wut -n "__fish_use_subcommand" -a "init" -d "Print shell integration"
complete -c wut -n "__fish_use_subcommand" -a "new" -d "Create a new worktree"
complete -c wut -n "__fish_use_subcommand" -a "list" -d "List all worktrees"
complete -c wut -n "__fish_use_subcommand" -a "go" -d "Go to worktree"
complete -c wut -n "__fish_use_subcommand" -a "path" -d "Print path to worktree"
complete -c wut -n "__fish_use_subcommand" -a "rm" -d "Remove worktree and delete branch"

# Global options
complete -c wut -s h -l help -d "Show help"
complete -c wut -s V -l version -d "Show version"

# new command options
complete -c wut -n "__fish_seen_subcommand_from new" -l from -d "Create from ref" -xa "(git for-each-ref --format='%(refname:short)' 2>/dev/null)"

# go command - complete with branches
complete -c wut -n "__fish_seen_subcommand_from go" -xa "(__wut_branches)"

# path command - complete with branches
complete -c wut -n "__fish_seen_subcommand_from path" -xa "(__wut_branches)"

# rm command options and branches
complete -c wut -n "__fish_seen_subcommand_from rm" -l force -d "Force removal"
complete -c wut -n "__fish_seen_subcommand_from rm" -xa "(__wut_branches)"
