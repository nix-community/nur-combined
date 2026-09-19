{
  lib,
  pkgs,
  maintainers,
  ...
}:
let
  version = "1.6.1";

  src = pkgs.fetchurl {
    url = "https://github.com/samuelthomas2774/nxapi/releases/download/v${version}/Nintendo.Switch.Online-${version}.AppImage";
    hash = "sha256-7klyvODfQXVWjYc2Bgv8cKP1PmXSkHNUmzu2QWg41ek=";
  };
in
pkgs.appimageTools.wrapType2 rec {
  pname = "nxapi-app";
  inherit version src;

  extraInstallCommands =
    let
      contents = pkgs.appimageTools.extract { inherit pname version src; };
    in
    ''
      mkdir -p $out/share/{applications,lib/nxapi}

      cp -r ${contents}/locales "$out/share/lib/nxapi"
      cp -r ${contents}/usr/share/* "$out/share"

      cp "${contents}/${pname}.desktop" "$out/share/applications/"
    '';

  meta = with lib; {
    description = "Nintendo Switch Online/Parental Controls app APIs - Electron app";
    homepage = "https://github.com/samuelthomas2774/nxapi";
    changelog = "https://github.com/samuelthomas2774/nxapi/releases/tag/v${version}";
    license = licenses.agpl3Plus;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "nxapi-app";
    platforms = platforms.linux;
    maintainers = with maintainers; [ greep ];
  };
}