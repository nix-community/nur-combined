{ stdenv
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
    version = "unstable-2020-09-06";

    src = fetchFromGitHub {
      owner = "lbonn";
      repo = "rofi";
      rev = "f01397106598ac154dbfeb2b6b458924c62be5ac";
      sha256 = "0qcs6sibc3478mslc6pysgvzxrnz05abpszgs3i7a41b3mjxp1rx";
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

    doCheck = true;

    meta = with stdenv.lib; {
      description = "Window switcher, run dialog and dmenu replacement (built for Wayland)";
      homepage = "https://github.com/lbonn/rofi";
      license = licenses.mit;
      maintainers = with maintainers; [ metadark ];
      platforms = platforms.linux;
    };
  };
}
