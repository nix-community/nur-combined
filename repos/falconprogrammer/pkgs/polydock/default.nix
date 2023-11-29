{
  lib,
  fetchFromGitHub,
  gtk3-x11,
  gjs,
  libwnck,
  gdk-pixbuf,
  callPackage,
  nodejs,
  wrapGAppsHook,
  gobject-introspection,
}:
let
  pnpm2nix = fetchFromGitHub {
    owner = "nzbr";
    repo = "pnpm2nix-nzbr";
    rev = "1f56072ef671ab08e262c030664ee1d50904bf77";
    hash = "sha256-3QFa3xOf/0JpzOrc+VSXmVq1Fu8k8/t1eF1n37X6xo8=";
  };

  pnpm_called = callPackage "${pnpm2nix}/derivation.nix" {};

  mkPnpmPackage = pnpm_called.mkPnpmPackage;

in
mkPnpmPackage rec {
  pname = "polydock";
  version = "master-2023-10-06";

  src = fetchFromGitHub {
    owner = "folke";
    repo = "polydock";
    rev = "d635052a9a46438cd0413db67590cce0e8c437ab";
    hash = "sha256-o9QX+evnFgDkrNo7/kh+n7bkjrlLsNHnnXCH7Ju8JP0=";
  };

  nativeBuildInputs = [
    nodejs.pkgs.pnpm
    wrapGAppsHook
    gobject-introspection
  ];

  buildInputs = [
    gjs
    gtk3-x11
    libwnck
    gdk-pixbuf
  ];

}
