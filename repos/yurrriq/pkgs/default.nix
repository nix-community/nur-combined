{ pkgs, sources ? import ../nix/sources.nix }:
let
  _nixpkgs = import sources.nixpkgs-unstable { };
  _nixpkgs-stable = import sources.nixpkgs { };
in
rec
{

  inherit (_nixpkgs)
    autojump
    browserpass
    conftest
    eksctl
    firefox
    kubelogin
    # TODO: next
    pass
    renderizer
    ripgrep
    scc
    sops
    thunderbird
    tomb
    yq
    ;

  bugwarrior = _nixpkgs.python38Packages.bugwarrior;

  ec2instanceconnectcli = _nixpkgs.python38Packages.callPackage ./development/tools/ec2instanceconnectcli { };

  elba = pkgs.callPackage ./development/tools/elba { };

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  icon-lang = _nixpkgs-stable.icon-lang.override {
    withGraphics = false;
  };

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab { };

  mcrl2 = pkgs.callPackage ./applications/science/logic/mcrl2 { };

  inherit (import sources.naal { }) naal;

  noweb = _nixpkgs-stable.noweb.override {
    inherit icon-lang;
  };
}
  // (import ./broken.nix)
