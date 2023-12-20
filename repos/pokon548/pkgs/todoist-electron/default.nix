{ lib, stdenv, appimageTools, fetchurl, asar }: let
  pname = "todoist-electron";
  version = "8.12.1";

  src = {
    x86_64-linux = fetchurl {
      url = "https://electron-dl.todoist.com/linux/Todoist-linux-${version}-x86_64.AppImage";
      hash = "sha256-fY5DnwxLLm66cjP/ikz3K+4brOrFr43GXsL7a+a0xXg=";
    };
    aarch64-linux = fetchurl {
      url = "https://electron-dl.todoist.com/linux/Todoist-linux-${version}-arm64.AppImage";
      hash = "sha256-vLFjCh2GOp35u3kSCmuhHE4H/WHThGDeYBssdDnj7wU=";
    };
  }.${stdenv.system} or (throw "${pname}-${version}: ${stdenv.system} is unsupported.");

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
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ kylesferrazza pokon548 ];
  };
}