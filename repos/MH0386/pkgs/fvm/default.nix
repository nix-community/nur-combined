{
  buildDartApplication ? (import <nixpkgs> { }).buildDartApplication,
  clang ? (import <nixpkgs> { }).clang,
  pkg-config ? (import <nixpkgs> { }).pkg-config,
  gtk3 ? (import <nixpkgs> { }).gtk3,
  cmake ? (import <nixpkgs> { }).cmake,
  fetchFromGitHub ? (import <nixpkgs> { }).fetchFromGitHub,
  nix-update-script ? (import <nixpkgs> { }).nix-update-script,
  lib ? (import <nixpkgs> { }).lib,
  glib ? (import <nixpkgs> { }).glib,
  cairo ? (import <nixpkgs> { }).cairo,
  pango ? (import <nixpkgs> { }).pango,
  atk ? (import <nixpkgs> { }).atk,
  gdk-pixbuf ? (import <nixpkgs> { }).gdk-pixbuf,
}:

buildDartApplication rec {
  pname = "fvm";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "leoafarias";
    repo = pname;
    tag = version;
    hash = "sha256-i7sJRBrS5qyW8uGlx+zg+wDxsxgmolTMcikHyOzv3Bs=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  buildInputs = [
    clang
    pkg-config
    gtk3
    cmake
    glib
    cairo
    pango
    atk
    gdk-pixbuf
  ];

  shellHook = ''
    export PKG_CONFIG_PATH="${lib.makeSearchPath "lib/pkgconfig" [
      gtk3.dev
      glib.dev
      cairo.dev
      pango.dev
      atk.dev
      gdk-pixbuf.dev
    ]}"
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [
      gtk3
      glib
      cairo
      pango
      atk
      gdk-pixbuf
    ]}:$LD_LIBRARY_PATH"
  '';

  dontUseCmakeConfigure = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Flutter Version Management: A simple CLI to manage Flutter SDK versions.";
    homepage = "https://fvm.app";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    #maintainers = [ lib.maintainers.MH0386 ];
  };
}
