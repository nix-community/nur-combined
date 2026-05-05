{
  appimageTools,
  lib,
  fetchurl,
  callPackage,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "openscreen";
  version = current.version;

  src = fetchurl {
    url = "https://github.com/siddharthvaddem/openscreen/releases/download/v${version}/Openscreen-Linux-latest.AppImage";
    hash = current.hash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D \
      ${appimageContents}/openscreen.desktop \
      $out/share/applications/openscreen.desktop

    cp -r \
      ${appimageContents}/usr/share/icons/hicolor \
      $out/share/icons/

    substituteInPlace $out/share/applications/openscreen.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "openscreen";
    versionFile = "pkgs/openscreen/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubRelease {
      owner = "siddharthvaddem";
      repo = "openscreen";
    }}";
  };

  meta = {
    description = "Screen recording and annotation tool";
    homepage = "https://github.com/siddharthvaddem/openscreen";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "openscreen";
  };
}
