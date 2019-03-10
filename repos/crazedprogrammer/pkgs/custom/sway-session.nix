{ stdenv, writeText, configFile ? null }:

let
  sessionStr = ''
    [Desktop Entry]
    Name=sway
    Comment=Sway Wayland session
    Exec=sway ${stdenv.lib.optionalString (configFile != null) "--config ${configFile}"}
    X-LightDM-Session-Type=wayland
  '';
  sessionFile = writeText "sway.desktop" sessionStr;
in

stdenv.mkDerivation {
  name = "sway-session";
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/xsessions
    cp ${sessionFile} $out/share/xsessions/sway.desktop
  '';
}
