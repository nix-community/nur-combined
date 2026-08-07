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
  scenefx_0_4,
  wlroots_0_19,
  libGL,
  cmake,
  libdrm,
  libgbm,
}: let
  pname = "mango";
in
  stdenv.mkDerivation rec {
    inherit pname;
    version = "0.12.3";

    src = fetchFromGitHub {
      owner = "DreamMaoMao";
      repo = "mangowc";
      tag = "0.12.3";
      hash = "sha256-cuOOgfufbGv0QIrRD6bAzaHiYXt32wxwt2Tzi+jAmwg=";
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
        scenefx_0_4
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
