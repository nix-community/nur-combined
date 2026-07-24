{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  callPackage,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "crabport";
  version = current.version;

  sourceMap = {
    x86_64-linux = fetchurl {
      url = "https://github.com/chi11321/CrabPort/releases/download/v${version}/CrabPort-v${version}-linux-x86_64.AppImage";
      hash = current.x86_64-linux-hash;
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/chi11321/CrabPort/releases/download/v${version}/CrabPort-v${version}-linux-aarch64.AppImage";
      hash = current.aarch64-linux-hash;
    };
  };

  src = sourceMap.${stdenv.hostPlatform.system};

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/CrabPort.desktop $out/share/applications/CrabPort.desktop
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    pname = "crabport";
    versionFile = "pkgs/crabport/version.json";
    fetchMetaCommand = "${(callPackage ../../utils/fetcher.nix { }).githubRelease {
      owner = "chi11321";
      repo = "CrabPort";
    }}";
  };

  meta = {
    description = "Modern, cross-platform SSH / SFTP client built with Rust and GPUI";
    homepage = "https://github.com/chi11321/CrabPort";
    license = lib.licenses.asl20;
    platforms = builtins.attrNames sourceMap;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = pname;
  };
}
