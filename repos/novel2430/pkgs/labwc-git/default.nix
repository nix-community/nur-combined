{
  lib,
  cairo,
  fetchFromGitHub,
  gettext,
  glib,
  libdrm,
  libinput,
  libpng,
  librsvg,
  libsfdo,
  libxcb,
  libxkbcommon,
  libxml2,
  meson,
  ninja,
  pango,
  pkg-config,
  scdoc,
  stdenv,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_18,
  xcbutilwm,
  xwayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "labwc";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "labwc";
    repo = "labwc";
    rev = "1043cbcca9737ea3cca5fddb4d73450b7ef35e32";
    hash = "sha256-mUAAyB0MpIgSSSxG9xu2EORAO94aWNkY8fH1FteInvU=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    cairo
    glib
    libdrm
    libinput
    libpng
    librsvg
    libsfdo
    libxcb
    libxkbcommon
    libxml2
    pango
    wayland
    wayland-protocols
    wlroots_0_18
    xcbutilwm
    xwayland
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  mesonFlags = [ (lib.mesonEnable "xwayland" true) ];

  strictDeps = true;

  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru = {
    providedSessions = [ "labwc" ];
  };

  meta = {
    homepage = "https://github.com/labwc/labwc";
    description = "Wayland stacking compositor, inspired by Openbox";
    changelog = "https://github.com/labwc/labwc/blob/master/NEWS.md";
    license = with lib.licenses; [ gpl2Plus ];
    mainProgram = "labwc";
    maintainers = with lib.maintainers; [ ];
    inherit (wayland.meta) platforms;
  };
})
