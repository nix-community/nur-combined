{ lib, appimageTools, fetchurl, asar }:
let
  pname = "chengla-electron";
  version = "1.0.8";

  src = fetchurl {
    url =
      "https://github.com/pokon548/chengla-for-linux/releases/download/v${version}/chengla-${version}.AppImage";
    sha256 = "sha256-sZmcyfbneQmG5QumOoOVEDCNR9kZvAJB12bevkpj6EU=";
    name = "${pname}-${version}.AppImage";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraPkgs = { pkgs, ... }@args: [
    pkgs.hidapi
  ] ++ appimageTools.defaultFhsEnvArgs.multiPkgs args;

  extraInstallCommands = ''
    # Add desktop convencience stuffs
    install -Dm444 ${appimageContents}/chengla-linux-unofficial.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/chengla-linux-unofficial.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/chengla-linux-unofficial.desktop \
      --replace 'Exec=AppRun' "Exec=$out/bin/${pname} --"
  '';

  meta = with lib; {
    description = "Chengla unofficial client for Linux";
    homepage = "https://github.com/pokon548/chengla-for-linux";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
