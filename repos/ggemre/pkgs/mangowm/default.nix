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
  libxcb-wm,
  xwayland,
  meson,
  ninja,
  scenefx,
  wlroots_0_19,
  libGL,
  nix-update-script,
  enableXWayland ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mango";
  version = "0.12.6";

  src = fetchFromGitHub {
    owner = "mangowm";
    repo = "mango";
    rev = finalAttrs.version;
    hash = "sha256-MXCXjnGPE+wagrHR8cxGTDhJO4xYp+aBQPApV3JG9XY=";
  };

  mesonFlags = [
    (lib.mesonEnable "xwayland" enableXWayland)
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
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
      scenefx
      libGL
    ]
    ++ lib.optionals enableXWayland [
      libX11
      libxcb-wm
      xwayland
    ];

  passthru = {
    providedSessions = ["mango"];
    updateScript = nix-update-script {};
  };

  meta = {
    mainProgram = "mango";
    description = "A streamlined but feature-rich Wayland compositor";
    homepage = "https://github.com/mangowm/mango";
    license = lib.licenses.gpl3Plus;
    maintainers = [];
    platforms = lib.platforms.linux;
  };
})
