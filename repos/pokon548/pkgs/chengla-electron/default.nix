{ lib, stdenv, callPackage, fetchurl, nixosTests }:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat = { x86_64-linux = "amd64"; }.${system} or throwSystem;

  archive_fmt = "zip";

  sha256 = {
    x86_64-linux = "sha256-eKEKjJCJ0u4VJ2KyXKVbcCMGYlRrncB8jAYbqe3dsfI=";
  }.${system} or throwSystem;

  sourceRoot = if stdenv.isDarwin then "" else ".";
in rec {
  inherit sourceRoot;

  # Please backport all compatible updates to the stable release.
  # This is important for the extension ecosystem.
  version = "1.0";
  pname = "chengla-electron";

  executableName = "chengla-linux-unofficial";
  longName = "Chengla Linux Unofficial";
  shortName = "chengla-linux-unofficial";

  src = fetchurl {
    url =
      "https://github.com/pokon548/chengla-for-linux/releases/download/v${version}/chengla-linux-unofficial-${plat}-${version}.${archive_fmt}";
    inherit sha256;
  };

  meta = with lib; {
    description = ''
      Unofficial Chengla Client for Linux
    '';
    longDescription = ''
      Unofficial Chengla Client for Linux, built on Electron
    '';
    homepage = "https://github.com/pokon548/chengla-for-linux";
    downloadPage = "https://github.com/pokon548/chengla-for-linux/releases";
    license = licenses.gpl3;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "chengla-linux-unofficial";
    platforms = [ "x86_64-linux" ];
  };
}
