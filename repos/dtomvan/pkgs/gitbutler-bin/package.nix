{
  lib,
  appimageTools,
  fetchzip,
}:
let
  pname = "gitbutler";
  version = "0.15.1";

  src = fetchzip {
    url = "https://releases.gitbutler.com/releases/release/0.15.1-2163/linux/x86_64/GitButler_0.15.1_amd64.AppImage.tar.gz";
    hash = "sha256-PB6Fnzy+dsJWS6sXkiuDcF9PXLHolB4VUbhoFTbAwac=";
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
