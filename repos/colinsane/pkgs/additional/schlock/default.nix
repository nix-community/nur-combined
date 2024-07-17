{
  lib,
  stdenv,
  cairo,
  copyDesktopItems,
  fetchFromGitHub,
  fetchzip,
  gdk-pixbuf,
  getconf,
  libsodium,
  libxkbcommon,
  makeDesktopItem,
  meson,
  ninja,
  openssl,
  pam,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
# hash strength, from <https://libsodium.gitbook.io/doc/password_hashing/default_phf#key-derivation>
# options:
# - "MODERATE" (default)
# - "INTERACTIVE" (vaguely, 4x faster to unlock than "moderate")
# - "SENSITIVE" (vaguely, 4x slower to decrypt than "moderate")
  pwhashDifficulty ? "INTERACTIVE",
}:
stdenv.mkDerivation rec {
  pname = "schlock";
  version = "unstable-2022-02-02";

  src = fetchFromGitHub {
    owner = "telent";
    repo = "schlock";
    rev = "f3dde16f074fd5b7482a253b9d26b4ead66dea82";
    hash = "sha256-Ot86vALt1kkzbBocwh9drCycbRIw2jMKJU4ODe9PYQM=";
  };

  # wlroots (and thereby sway) no longer supports the outdated zwlr_input_inhibit_manager_v1 protocol.
  # it was removed 2023/11: <https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/4440>
  # in favor of ext-session-lock-v1
  # - see: <https://wayland.app/protocols/wlr-input-inhibitor-unstable-v1>
  #
  # schlock errors if the compositor doesn't support that (for security reasons), but
  # schlock's approach is fundamentally flawed to begin with: so just patch out that check
  # until i have a longer-term solution.
  postPatch = ''
    substituteInPlace main.c \
      --replace-fail 'if (!state.input_inhibit_manager)' 'if (false)' \
      --replace-fail 'zwlr_input_inhibit_manager_v1_get_inhibitor' '// '
  '' + lib.optionalString (pwhashDifficulty != null) ''
    substituteInPlace mkpin.c \
      --replace-fail '_MODERATE' '_${pwhashDifficulty}'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];
  buildInputs = [
    cairo
    gdk-pixbuf
    libsodium
    libxkbcommon
    wayland
    wayland-protocols
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "schlock";
      # exec = "schlock -p $HOME/.config/schlock/schlock.pin";
      exec = ''/bin/sh -c "schlock -p \\$HOME/.config/schlock/schlock.pin"'';
      desktopName = "mobile screen locker";
    })
  ];

  meta = with lib; {
    description = "Touchscreen locker for Wayland";
    longDescription = ''
      schlock is a fork of Swaylock adapted for touchscreen devices.
    '';
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ colinsane ];
  };
}
