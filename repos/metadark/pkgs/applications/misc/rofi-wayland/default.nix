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
      fetchSubmodules = true;
      sha256 = "sha256-Kg8O4jKtzjwrz+wDm/TtqT0Vu+QaE1gCc5g5TMKeMNg=";
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
