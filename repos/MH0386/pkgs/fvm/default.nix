{
  buildDartApplication,
  clang,
  pkg-config,
  gtk3,
  cmake,
  fetchFromGitHub,
  nix-update-script,
  lib,
  glib,
  cairo,
  pango,
  atk,
  gdk-pixbuf,
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

  env = {
    FLUTTER_ROOT = "${src}/flutter";
    FVM_DIR = "${src}";
    FVM_DIR_BIN = "${env.FVM_DIR}/bin";
    PATH = "${gtk3.dev}/bin:${gtk3}/bin:$PATH";
    XDG_DATA_DIRS = "${gtk3.dev}/share:${gtk3}/share:$XDG_DATA_DIRS";
    GETTEXTDATADIRS = "${gtk3.dev}/share/gettext:$GETTEXTDATADIRS";
    GSETTINGS_SCHEMAS_PATH = "${gtk3.dev}/share/glib-2.0/schemas:$GSETTINGS_SCHEMAS_PATH";
    HOST_PATH = "${gtk3.dev}/bin:${gtk3}/bin:$HOST_PATH";
  };

  propagatedBuildInputs = [
    clang
    pkg-config
    gtk3.dev
    cmake
    glib.dev
    cairo.dev
    pango.dev
    atk.dev
    gdk-pixbuf.dev
  ];

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
