{ lib, appimageTools, fetchurl, asar }: let
  pname = "todoist-electron";
  version = "8.6.0";

  src = lib.warn
    "nur.repos.pokon548.todoist-electron will be deprecated as soon as nixpkgs merge latest commits. See https://github.com/NixOS/nixpkgs/pull/250120"
    fetchurl {
      url =
        "https://electron-dl.todoist.com/linux/Todoist-linux-x86_64-${version}.AppImage";
      hash = "sha256-LjztKgpPm4RN1Pn5gIiPg8UCO095kzTQ9BTEG5Rlv10=";
    };

  appimageContents = (appimageTools.extract { inherit pname version src; }).overrideAttrs (oA: {
    buildCommand = ''
      ${oA.buildCommand}

      # Get rid of the autoupdater
      ${asar}/bin/asar extract $out/resources/app.asar app
      sed -i 's/async isUpdateAvailable.*/async isUpdateAvailable(updateInfo) { return false;/g' app/node_modules/electron-updater/out/AppUpdater.js
      ${asar}/bin/asar pack app $out/resources/app.asar
    '';
  });

in appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  extraPkgs = { pkgs, ... }@args: [
    pkgs.hidapi
  ] ++ appimageTools.defaultFhsEnvArgs.multiPkgs args;

  extraInstallCommands = ''
    # Add desktop convencience stuff
    mv $out/bin/{${pname}-*,${pname}}
    install -Dm444 ${appimageContents}/todoist.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/todoist.png -t $out/share/pixmaps
    substituteInPlace $out/share/applications/todoist.desktop \
      --replace 'Exec=AppRun' "Exec=$out/bin/${pname} --"
  '';

  meta = with lib; {
    homepage = "https://todoist.com";
    description = "The official Todoist electron app";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ i077 kylesferrazza pokon548 ];
  };
}