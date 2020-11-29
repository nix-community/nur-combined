{ lib
, stdenv
, rofi
, fetchFromGitHub
, meson
, ninja
, pkg-config
, bison
, check
, flex
, librsvg
, libstartup_notification
, libxkbcommon
, pango
, wayland
, wayland-protocols
, xcbutilwm
, xcbutilxrm
}:

rofi.override {
  rofi-unwrapped = stdenv.mkDerivation rec {
    pname = "rofi-wayland";
    version = "1.6.1";

    src = fetchFromGitHub {
      owner = "lbonn";
      repo = "rofi";
      rev = "${version}-wayland";
      sha256 = "1n1hkv14qfcqfc15h4qswjxiagd9xps9n0zcrwmkrkmd6bi0w3ra";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [
      ninja
      meson
      pkg-config
    ];

    buildInputs = [
      bison
      check
      flex
      librsvg
      libstartup_notification
      libxkbcommon
      pango
      wayland
      wayland-protocols
      xcbutilwm
      xcbutilxrm
    ];

    mesonFlags = [
      "-Dwayland=enabled"
    ];

    # Fixes:
    # ../source/rofi-icon-fetcher.c:190:17: error: format not a string literal and no format arguments [-Werror=format-security]
    hardeningDisable = [ "format" ];

    doCheck = true;

    meta = with lib; {
      description = "Window switcher, run dialog and dmenu replacement (built for Wayland)";
      homepage = "https://github.com/lbonn/rofi";
      license = licenses.mit;
      maintainers = with maintainers; [ metadark ];
      platforms = platforms.linux;
    };
  };
}
