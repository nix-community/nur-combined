{
  cairo,
  fetchFromGitHub,
  glib,
  harfbuzz,
  lib,
  libxkbcommon,
  pango,
  pkg-config,
  stdenv,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation rec {
  pname = "wvkbd-mk";
  version = "unstable-2024-01-01";

  src = fetchFromGitHub {
    owner = "federvieh";
    repo = "wvkbd";
    rev = "bf310be0509b8d217670ef8780765517726a4228";
    hash = "sha256-xZ9HG0nwmLvHhwwXfnIO3UIzE0til54sNZ2aV6MEIuo=";
  };

  # tell it where to find pkg-config when cross-compiling:
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "pkg-config" "$PKG_CONFIG"
  '';

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];
  buildInputs = [
    cairo
    glib
    harfbuzz
    libxkbcommon
    pango
    wayland
  ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/federvieh/wvkbd";
    description = "On-screen keyboard for wlroots optimized for one finger input";
    longDescription = ''
      wvkbd-mk is optimized for single finger input and is quite a different
      from other keyboards. It uses a 3 by 3 grid for the main input. Keys are
      pressed by tapping or swiping the grid.

      N.B.: invoke as `wvkbd-anihortes --motion-keys` or else it behaves like
      stock `wvkbd` with a funny layout.
    '';
    maintainers = [ maintainers.colinsane ];
    platforms = platforms.linux;
    license = licenses.gpl3Plus;
    mainProgram = "wvkbd-anihortes";
  };
}

