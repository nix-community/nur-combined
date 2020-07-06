{ pkgs, ... }:

{
  imports = [
    ./emacs.nix
    ./go.nix
    ./js.nix
    ./lisp.nix
    ./mr.nix
    ./nix.nix
    ./python.nix
  ];

  home.extraOutputsToInstall = [ "doc" "info" "devdoc" ];

  home.packages = with pkgs; [
    binutils
    cmake
    fswatch
    gnumake
    jq
    mercurial
    shfmt
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

  xdg.configFile."nr/dev" = {
    text = builtins.toJSON [
      { cmd = "yq"; }
      { cmd = "lnav"; }
      { cmd = "miniserve"; }
      { cmd = "licensor"; }
      { cmd = "yamllint"; pkg = "python37Packages.yamllint"; }
      { cmd = "http"; pkg = "httpie"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr dev";
  };

}
