{ lib, pkgs }:

let

  _nixpkgs = lib.pinnedNixpkgs (lib.fromJSONFile ../nix/nixpkgs.json);

in

rec {
  inherit (lib) buildK8sEnv;

  inherit (_nixpkgs)
    autojump
    # FIXME: browserpass
    cachix
    conftest
    # elixir_1_8
    eksctl
    expat # NOTE: https://github.com/NixOS/nixpkgs/issues/71075
    firefox
    # TODO: next
    pass
    # FIXME: ripgrep
    # FIXME: sops
    thunderbird
    tomb
    ;

  browserpass = _nixpkgs.callPackage ./tools/security/browserpass {};

  elba = pkgs.callPackage ./development/tools/elba {};

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  icon-lang = _nixpkgs.icon-lang.override {
    withGraphics = false;
  };

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  openlilylib-fonts = pkgs.callPackage ./misc/lilypond/fonts.nix { };
  lilypond = pkgs.callPackage ./misc/lilypond { guile = pkgs.guile_1_8; };
  lilypond-unstable = pkgs.callPackage ./misc/lilypond/unstable.nix {
    inherit lilypond;
  };
  lilypond-with-fonts = pkgs.callPackage ./misc/lilypond/with-fonts.nix {
    lilypond = lilypond-unstable;
  };

  noweb = _nixpkgs.noweb.override {
    inherit icon-lang;
  };

  python35Packages = pkgs.python35Packages // {
    inherit ((lib.pinnedNixpkgs {
      rev = "97ce5d27e87af578dc964a0dba740c7531d75590";
      sha256 = "1w6j98kh6x784z5dax36pd87cxsyfi53gq67hgwwkdbnmww2q5jj";
    }).python35Packages) bugwarrior;
  };

  renderizer = pkgs.callPackage ./development/tools/renderizer {};

  ripgrep = _nixpkgs.callPackage ./tools/text/ripgrep {
    inherit (_nixpkgs.darwin.apple_sdk.frameworks) Security;
  };

  rust-cbindgen = _nixpkgs.rust-cbindgen.overrideAttrs(_: {
    cargoSha256 = "1l2dmvpg7114g7kczhaxv97037wdjah174xa992hv90a79kiz8da";
  });

  sops = _nixpkgs.callPackage ./tools/security/sops {};

} // (if pkgs.stdenv.isLinux then {

  apfs-fuse = pkgs.callPackage ./os-specific/linux/apfs-fuse {
    fuse = pkgs.fuse3;
  };

} else {}) // {

  gap-pygments-lexer.meta.broken = true;

  openlilylib-fonts.meta.broken = true;
  lilypond.meta.broken = true;
  lilypond-unstable.meta.broken = true;
  lilypond-with-fonts.meta.broken = true;

}
