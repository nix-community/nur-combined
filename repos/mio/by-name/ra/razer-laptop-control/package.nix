{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  hidapi,
  systemd,
  glib,
  pango,
  gtk3,
}:

rustPlatform.buildRustPackage rec {
  pname = "razer-laptop-control";
  version = "0.2.0-unstable-2026-04-02";

  src = fetchFromGitHub {
    owner = "JosuGZ";
    repo = "razer-laptop-control";
    rev = "2c224ef0cda712f826056450d89e12c5f7bf3d0d";
    hash = "sha256-p8hz8FTmoksMh1qYi6Hy/q6BAN1PQNaQ2b9lzQDA2+k=";
  };

  cargoHash = "sha256-F8sfQULz3hA+sCXc/hePaQzUilgf5OMe1oPS1UBb57s=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus.dev
    hidapi
    systemd
    glib
    pango
    gtk3
  ];

  postBuild = ''
    # Install .desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/razer-settings.desktop <<EOF
    [Desktop Entry]
    Name=Razer Settings
    Exec=$out/bin/razer-settings
    Type=Application
    Categories=Utility;
    EOF
    chmod +x $out/share/applications/razer-settings.desktop
  '';

  postInstall = ''
    mkdir -p $out/lib/udev/rules.d
    mkdir -p $out/libexec
    mv $out/bin/daemon $out/libexec
    cp razer_control_gui/data/udev/99-hidraw-permissions.rules $out/lib/udev/rules.d/99-hidraw-permissions.rules
  '';

  meta = with lib; {
    description = "Control Razer laptop hardware";
    homepage = "https://github.com/JosuGZ/razer-laptop-control";
    license = licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "razer-settings";
  };
}
