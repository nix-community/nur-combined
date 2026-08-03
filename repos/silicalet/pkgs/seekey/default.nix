{
  lib,
  dbus,
  desktop-file-utils,
  fetchFromGitHub,
  gettext,
  gtk4,
  gtk4-layer-shell,
  json-glib,
  libevdev,
  ncurses,
  nix-update-script,
  pkg-config,
  stdenv,
  versionCheckHook,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seekey";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "Nakanomk";
    repo = "Seekey";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rwVPvSI30BZrIH5a94VzHPQDN1Y7AGHXwttb8nfeNeM=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [
    gettext
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    json-glib
    libevdev
    ncurses
  ];

  nativeCheckInputs = [
    dbus
    desktop-file-utils
  ];
  doCheck = true;

  postInstall = ''
    install -Dm644 /dev/stdin "$out/lib/udev/rules.d/99-seekey.rules" <<'EOF'
    # Seekey: allow members of the input group to access input event devices.
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0660"
    EOF
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wayland keyboard visualizer with floating key bubbles";
    homepage = "https://github.com/Nakanomk/Seekey";
    changelog = "https://github.com/Nakanomk/Seekey/compare/v0.2.1...v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "seekey";
    platforms = lib.platforms.linux;
  };
})
