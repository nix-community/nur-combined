{ pkgs
, ...
}:

let
  inherit (pkgs) perlnavigator;

in {
  # https://devenv.sh/packages/
  packages = [
    perlnavigator
  ];

  languages = {
    perl.enable = true;
    nix.enable = true;
  };

  enterShell = ''
    # FIXME: Use https://github.com/numtide/devshell/blob/main/extra/language/perl.nix
  '';
}
