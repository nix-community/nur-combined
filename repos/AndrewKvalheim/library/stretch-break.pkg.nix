{ copyDesktopItems
, fetchFromGitHub
, lib
, nix-update-script
, rustPlatform
, xdg-utils

  # Dependencies
, alsa-lib
, dbus
, gdk-pixbuf
, glib
, gobject-introspection
, graphene
, gtk4
, libadwaita
, libnotify
, libx11
, libxscrnsaver
, pango
, pkg-config
}:

let
  inherit (builtins) placeholder;
  inherit (lib) escapeShellArg licenses;
in
rustPlatform.buildRustPackage (stretch-break: {
  pname = "stretch-break";
  version = "0.1.9";
  meta = {
    description = "Helps you take regular breaks from using your computer";
    homepage = "https://github.com/pieterdd/StretchBreak";
    license = licenses.gpl3;
    mainProgram = "stretch-break";
  };

  passthru.updateScript = nix-update-script { };

  src = fetchFromGitHub {
    owner = "pieterdd";
    repo = "StretchBreak";
    rev = "refs/tags/${stretch-break.version}";
    hash = "sha256-gKQsoitJfGVUnpEHC4qXdesECvylJluwRDXtoNZfSFI=";
  };

  postPatch = ''
    substituteInPlace 'meta/io.github.pieterdd.StretchBreak.desktop' \
      --replace-fail 'Exec=stretch-break' 'Exec=${placeholder "out"}/bin/stretch-break'
  '';

  cargoHash = "sha256-LyifQ44aS7kkm7Cd6baSu5lYAWfKpDOlRFXGQFQLNU4=";

  nativeBuildInputs = [
    copyDesktopItems
    gobject-introspection
    pkg-config
    xdg-utils
  ];
  buildInputs = [
    alsa-lib
    dbus
    gdk-pixbuf
    glib
    graphene
    gtk4
    libadwaita
    libnotify
    libx11
    libxscrnsaver
    pango
  ];

  desktopItems = [ "meta/io.github.pieterdd.StretchBreak.desktop" ];
  postInstall = ''
    mkdir --parents "$out/share/dbus-1/services"
    substitute \
      "$src/meta/io.github.pieterdd.StretchBreak.Core.service" \
      "$out/share/dbus-1/services/io.github.pieterdd.StretchBreak.Core.service" \
      --replace-fail '/usr/bin' "$out/bin"

    env XDG_DATA_HOME="$out/share" \
      xdg-icon-resource install --noupdate --novendor \
        --context 'apps' --size '256' "$src/meta/logo-color-256x256.png" 'io.github.pieterdd.StretchBreak'
  '';

  doInstallCheck = true;
  # Pending compatibility with versionCheckHook
  installCheckPhase = ''
    help="$($out/bin/${escapeShellArg stretch-break.meta.mainProgram} --help)"
    echo "$help"
    [[ "$help" == *'Usage: stretch-break'* ]]
    [[ "$help" != *'version'* ]]
    [[ "$help" != *${escapeShellArg stretch-break.version}* ]]
  '';
})
