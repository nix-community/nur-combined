{
  lib,
  appimageTools,
  fetchzip,
}:
let
  pname = "gitbutler";
  version = "0.18.3";

  src = fetchzip {
    url = "https://releases.gitbutler.com/releases/release/0.18.3-2698/linux/x86_64/GitButler_0.18.3_amd64.AppImage.tar.gz";
    hash = "sha256-zoUzb+0EnEeCp28pxK/J76IklJ1JUqo/61XTyhMKPM0=";
  };
in
appimageTools.wrapType2 {
  inherit pname version;

  src = "${src}/*"; # because it's a tarball or something, WTF is a squashfs or even AppImage.gz??

  passthru.updateScript = ./update.nu;

  meta = {
    description = "Git branch management tool";
    homepage = "https://github.com/gitbutlerapp/gitbutler";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux" # I don't wanna support more
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "gitbutler";
  };
}
