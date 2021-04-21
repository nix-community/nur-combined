{ fetchFromGitHub, lib, openssl, pkg-config, rustPlatform, glib, cairo, pango, atk, gdk-pixbuf, gtk3-x11, xdotool }:

rustPlatform.buildRustPackage rec {
  name = "toonmux";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  cargoPatches = [ ./cargo-lock.patch ];
  cargoSha256 = "13wbkz0qh9vmfh3db051i2ck4pw515hca3lgq4f3cf0ad8zlls2x";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    glib.dev
    atk.dev
    cairo.dev
    gdk-pixbuf.dev
    pango.dev
    gtk3-x11.dev
    xdotool
  ];

  meta = with lib; {
    description = "Linux multi-toon controller for Toontown-based MMORPGs";
    homepage = "https://github.com/JonathanHelianthicusDoe/toonmux";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.reedrw ];
    platforms = platforms.linux;
  };
}
