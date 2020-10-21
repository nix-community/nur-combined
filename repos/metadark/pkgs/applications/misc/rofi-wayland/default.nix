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
    version = "unstable-2020-10-18";

    src = fetchFromGitHub {
      owner = "lbonn";
      repo = "rofi";
      rev = "87b48ce7550d8875aaa0b4ea28d69c898755e8fc";
      sha256 = "11qr3b826r53jdqq8p0bkngk4srmv8ld3j3zrc2s3g7c9h57wdix";
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
