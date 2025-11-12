{
  fetchFromGitHub,
  lib,
  libX11,
  libinput,
  libxcb,
  libxkbcommon,
  pcre2,
  pixman,
  pkg-config,
  stdenv,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xcbutilwm,
  xwayland,
  enableXWayland ? true,
  meson,
  ninja,
  scenefx,
  wlroots_0_19,
  libGL,
  cmake,
  libdrm,
  libgbm,
}: let
  pname = "mango";
  scenefx-0-4-1 = scenefx.overrideAttrs (old: {
    version = "0.4.1";
    src = fetchFromGitHub {
      owner = "wlrfx";
      repo = "scenefx";
      tag = "0.4.1";
      hash = "sha256-XD5EcquaHBg5spsN06fPHAjVCb1vOMM7oxmjZZ/PxIE=";
    };
    buildInputs = [
      libdrm
      libGL
      libxkbcommon
      libgbm
      libxcb
      xcbutilwm
      pixman
      wayland
      wayland-protocols
      wlroots_0_19
    ];
  });
in
  stdenv.mkDerivation rec {
    inherit pname;
    version = "0.10.5";

    src = fetchFromGitHub {
      owner = "DreamMaoMao";
      repo = "mangowc";
      tag = "0.10.5";
      hash = "sha256-ZESyUtCiIQh6R0VYAo8YaP95Damw3MJVvKy5qU3pgTA=";
    };

    nativeBuildInputs = [
      meson
      ninja
      pkg-config
      wayland-scanner
      cmake
    ];

    buildInputs =
      [
        libinput
        libxcb
        libxkbcommon
        pcre2
        pixman
        wayland
        wayland-protocols
        wlroots_0_19
        scenefx-0-4-1
        libGL
      ]
      ++ lib.optionals enableXWayland [
        libX11
        xcbutilwm
        xwayland
      ];

    passthru = {
      providedSessions = ["mango"];
    };

    meta = {
      mainProgram = "mango";
      description = "A streamlined but feature-rich Wayland compositor";
      homepage = "https://github.com/DreamMaoMao/mango";
      license = lib.licenses.gpl3Plus;
      maintainers = [];
      platforms = lib.platforms.unix;
    };
  }
