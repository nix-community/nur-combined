{ pre-commit-hooks-nix, ... }:
{
  imports = [ pre-commit-hooks-nix.flakeModule ];

  perSystem = _: {
    pre-commit = {
      check.enable = true;
      settings = {
        excludes = [
          "_sources/.*"
          "sources\\.json"
          ".*\\.patch"
          "README\\.md"
          ".envrc"
          ".*\\.age"
        ];
        hooks = {
          check-added-large-files.enable = true;
          check-builtin-literals.enable = true;
          check-case-conflicts.enable = true;
          check-executables-have-shebangs.enable = true;
          check-json.enable = true;
          check-merge-conflicts.enable = true;
          check-python.enable = true;
          check-shebang-scripts-are-executable.enable = true;
          check-symlinks.enable = true;
          check-toml.enable = true;
          check-vcs-permalinks.enable = true;
          check-yaml.enable = true;
          detect-private-keys.enable = true;
          end-of-file-fixer.enable = true;
          fix-byte-order-marker.enable = true;
          flake-checker = {
            enable = true;
            args = [
              "--check-outdated"
              "false"
            ];
          };
          flynt.enable = true;
          nil.enable = true;
          pyupgrade.enable = true;
          shellcheck = {
            enable = true;
            args = [
              "-S"
              "error"
            ];
          };
          treefmt.enable = true;
          trim-trailing-whitespace.enable = true;
        };
      };
    };
  };
}
