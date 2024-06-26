{ pkgs
, ...
}:

let
  inherit (pkgs) callPackage;
  inherit (pkgs.nodePackages) bash-language-server;
  package = callPackage ./package.nix { };

in {
  packages = [
    bash-language-server
    package
  ];

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep "2.42.0"
  '';

  # https://devenv.sh/languages/
  languages = {
    nix.enable = true;
    shell.enable = true;
  };

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks.shellcheck.enable = true;
}
