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
let
  labwc-ws4waybar = stdenv.mkDerivation {
    pname = "labwc-ws4waybar";
    version = "0.0.1";
    src = fetchFromGitHub {
      owner = "jenav";
      repo = "labwc-ws4waybar";
      rev = "a6a6bada97f6073f1f594fced3a05f32da96da3e";
      sha256 = "sha256-4ykzclqExSmORkSA/jA1lnFlyk2kXaQAlArk9QQ1BSY=";
    };
    installPhase = ''
      mkdir -p $out
      cp 0000-expose-current-workspace.patch $out
    '';
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "labwc";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "labwc";
    repo = "labwc";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-TXxdjMkzZQoCqkZBqus5eCBEhA/nvxNNXaNHUTGFQDQ=";
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

  patches = [
    "${labwc-ws4waybar}/0000-expose-current-workspace.patch"
  ];

  mesonFlags = [ (lib.mesonEnable "xwayland" true) ];

  strictDeps = true;

  doInstallCheck = true;
  versionCheckProgramArg = "--version";

  passthru = {
    providedSessions = [ "labwc" ];
  };

  meta = {
    homepage = "https://github.com/labwc/labwc";
    description = "Wayland stacking compositor, inspired by Openbox (Use jenav/labwc-ws4waybar Patch)";
    changelog = "https://github.com/labwc/labwc/blob/master/NEWS.md";
    license = with lib.licenses; [ gpl2Plus ];
    mainProgram = "labwc";
    maintainers = with lib.maintainers; [ ];
    inherit (wayland.meta) platforms;
  };
})
