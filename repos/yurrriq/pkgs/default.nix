{ lib, pkgs, sources ? import ../nix/sources.nix }:

let

  _nixpkgs = import sources.nixpkgs-unstable {};

  _nixpkgs-stable = import sources.nixpkgs {};

in

rec {
  inherit (lib) buildK8sEnv;

  inherit (_nixpkgs-stable)
    cachix;

  inherit (_nixpkgs)
    autojump
    browserpass
    # FIXME: cachix
    conftest
    # elixir_1_8
    eksctl
    firefox
    # TODO: next
    pass
    ripgrep
    sops
    thunderbird
    tomb
    ;

  elba = pkgs.callPackage ./development/tools/elba {};

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  icon-lang = _nixpkgs-stable.icon-lang.override {
    withGraphics = false;
  };

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  openlilylib-fonts = pkgs.callPackage ./misc/lilypond/fonts.nix { };

  lilypond = pkgs.callPackage ./misc/lilypond { guile = pkgs.guile_1_8; };

  lilypond-unstable = pkgs.callPackage ./misc/lilypond/unstable.nix {
    inherit lilypond;
  };

  lilypond-improviso-lilyjazz = lilypond-unstable.with-fonts [
    "improviso"
    "lilyjazz"
  ];

  # FIXME: mcrl2 = pkgs.callPackage ./applications/science/logic/mcrl2 {};

  noweb = _nixpkgs-stable.noweb.override {
    inherit icon-lang;
  };

  python38Packages = pkgs.python38Packages // {
    inherit ((import sources.nixpkgs-66234 {}).python38Packages) bugwarrior;
  };

  renderizer = pkgs.callPackage ./development/tools/renderizer {};

  rust-cbindgen = _nixpkgs.rust-cbindgen.overrideAttrs(_: {
    cargoSha256 = "1l2dmvpg7114g7kczhaxv97037wdjah174xa992hv90a79kiz8da";
  });

} // (import ./broken.nix { inherit pkgs; })
