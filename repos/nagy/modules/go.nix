{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.go
    pkgs.gopls

    pkgs.ginkgo

    pkgs.golangci-lint

    # Debugger
    pkgs.delve
    # pkgs.gdlv
  ];
}
