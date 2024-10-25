{ pre-commit-hooks-nix, ... }:
{
  imports = [ pre-commit-hooks-nix.flakeModule ];

  perSystem =
    {
      options,
      config,
      pkgs,
      ...
    }:
    {
      pre-commit = {
        check.enable = true;
        settings = {
          excludes = [ "_sources/.*" ];
          hooks = {
            actionlint.enable = true;
            check-added-large-files.enable = true;
            check-builtin-literals.enable = true;
            check-case-conflicts.enable = true;
            check-json.enable = true;
            check-merge-conflicts.enable = true;
            check-python.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            check-symlinks.enable = true;
            check-toml.enable = true;
            check-vcs-permalinks.enable = true;
            check-yaml.enable = true;
            detect-private-keys.enable = true;
            fix-byte-order-marker.enable = true;
            flake-checker.enable = true;
            flynt.enable = true;
            nil.enable = true;
            treefmt = {
              enable = true;
              entry =
                let
                  treefmt = if options ? treefmt then config.treefmt.build.wrapper else pkgs.treefmt;
                in
                "${treefmt}/bin/treefmt --clear-cache --fail-on-change";
              always_run = true;
              pass_filenames = false;
            };
          };
        };
      };
    };
}
