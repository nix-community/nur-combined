{ config, pkgs, ... }:

{
  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}";
  };
  home.packages = with pkgs; [
    gcc
    go
    godef
    golangci-lint
    golint
    gopkgs
    go-outline
    go-symbols
    delve
    goimports
    # vendoring tools
    dep
    # misc
    protobuf
    my.protobuild
    my.ram
    my.sec
    my.esc
    my.yaspell
  ];
  xdg.configFile."nr/dev.go" = {
    text = builtins.toJSON [
      { cmd = "pprof"; chan = "unstable"; }
      { cmd = "vndr"; chan = "unstable"; }
      { cmd = "go2nix"; }
      { cmd = "dep2nix"; }
    ];
    onChange = "${pkgs.my.nr}/bin/nr dev.go";
  };
}
