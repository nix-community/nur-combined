{ pkgs, ... }:

{
  imports = [
    ./go.nix
    ./js.nix
    ./mr.nix
    ./nix.nix
    ./python.nix
  ];

  home.extraOutputsToInstall = [ "doc" "info" "devdoc" ];

  home.packages = with pkgs; [
    binutils
    cmake
    codespell
    # devenv
    difftastic
    fswatch
    gnumake
    gron
    gum
    jq
    markdownlint-cli
    minica
    moreutils
    pre-commit
    shellcheck
    shfmt
    tldr
    tmate
    vale
    yamllint
    yamlfmt
    yq-go
  ];

  home.file.".ignore".text = ''
    *.swp
    *~
    **/VENDOR-LICENSE
  '';

  home.file.gdbinit = {
    target = ".gdbinit";
    text = ''
      set auto-load safe-path /
    '';
  };

}
