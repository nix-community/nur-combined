{ lib, appimageTools, fetchurl, asar }:
let
  pname = "ntfy-naive";
  version = "1.0.1";

  src = fetchurl {
    url =
      "https://github.com/pokon548/ntfy-naive/releases/download/v${version}/Ntfy.Native-${version}.AppImage";
    hash = "sha256-+7MU3+cLdIDk2o0ZPkmJmyb9k4KBlSnINspsqe1+kaQ=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

in
appimageTools.wrapAppImage {
  inherit pname version;
  name = pname;
  src = appimageContents;

  extraPkgs = { pkgs, ... }@args: [
    pkgs.hidapi
  ] ++ appimageTools.defaultFhsEnvArgs.multiPkgs args;

  extraInstallCommands = ''
    # Add desktop convencience stuff
    install -Dm444 ${appimageContents}/ntfy-native.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/ntfy-native.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/ntfy-native.desktop \
      --replace 'Exec=AppRun' "Exec=$out/bin/${pname} --"
  '';

  meta = with lib; {
    description = "A truly naive, cross-platform ntfy client that lives in your tray. Period.";
    homepage = "https://github.com/pokon548/ntfy-naive";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
