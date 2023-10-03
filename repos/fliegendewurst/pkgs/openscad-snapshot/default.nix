{ lib, fetchurl, appimageTools, openscad, makeWrapper }:

let
  pname = "openscad";
  version = "2023.08.25.ai16051";
  src = fetchurl {
    url = "https://files.openscad.org/snapshots/OpenSCAD-${version}-x86_64.AppImage";
    sha256 = "sha256-mEGmkL2lL7JxK0nRPLtnfg4vxtkK3URz351eyuRHZPE=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram $out/bin/${pname}-${version} \
        --unset QT_PLUGIN_PATH
  '';

  meta = with lib; {
    inherit (openscad.meta);
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
