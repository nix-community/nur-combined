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
    version = "unstable-2020-09-02";

    src = fetchFromGitHub {
      owner = "lbonn";
      repo = "rofi";
      rev = "2e1e362fd31a64fa4159b26fd645bbf7611ca4c8";
      sha256 = "16mbqwkirwqi21y2llzvbmrdg8arwz8rf7f9yg7f2rlfwpkg6yym";
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
