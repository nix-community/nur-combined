function nfl
    set -l flags "--commit-lock-file"
    for flake in $argv
        set -a flags "--update-input" "$flake"
    end
    nix flake lock $flags
end
