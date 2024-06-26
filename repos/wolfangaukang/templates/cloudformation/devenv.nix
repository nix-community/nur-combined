{ pkgs
, ...
}:

let
  inherit (pkgs) awscli2 cfn-nag yaml-language-server;
  inherit (pkgs.python3Packages) cfn-lint;

in {
  packages = [
    awscli2
    cfn-lint
    cfn-nag
    yaml-language-server
  ];

  #enterTest = ''
    #echo "Running tests"
    #cfn-lint *
    #cfn_nag *
  #'';

  languages.nix.enable = true;

  pre-commit.hooks.yamllint.enable = true;
}
