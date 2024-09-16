function nfl
    set -l flags "--commit-lock-file"
    nix flake update $flags $argv
end
