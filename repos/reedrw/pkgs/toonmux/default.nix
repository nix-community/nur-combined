{ fetchFromGitHub, lib, openssl, pkg-config, rustPlatform, glib, cairo, pango, atk, gdk-pixbuf, gtk3-x11, xdotool }:

rustPlatform.buildRustPackage {
  name = "toonmux";

  src = fetchFromGitHub (lib.importJSON ./source.json);

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-kXJjfwQOpRll4ybBjHKM4r2bd+qK6JULQiBODbPoMzI=";

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
