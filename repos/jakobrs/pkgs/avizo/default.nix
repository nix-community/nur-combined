{ stdenv, lib, fetchFromGitHub,
  meson, pkg-config, ninja, vala,
  glib, gtk3, gtk-layer-shell, gobject-introspection }:

stdenv.mkDerivation {
  pname = "avizo";
  version = "unstable-2020-11-27";

  src = fetchFromGitHub {
    owner = "misterdanb";
    repo = "avizo";
    rev = "21b0bf5bfd406c53b12aaf0a732ad87b5a2655f6";
    hash = "sha256:14sa7w5psrvzd9dywmrw2qnqg610g5r6l49x0h8iw02ghfrxkrbx";
  };

  nativeBuildInputs = [ meson pkg-config ninja vala ];
  buildInputs = [ glib gtk3 gtk-layer-shell gobject-introspection ];

  postInstall = ''
    mv $out/bin/lightctl $out/bin/avizo-lightctl
    mv $out/bin/volumectl $out/bin/avizo-volumectl
  '';

  meta = {
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.gpl3Only;
  };
}
