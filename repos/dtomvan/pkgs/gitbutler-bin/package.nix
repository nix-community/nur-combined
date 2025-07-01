{
  lib,
  appimageTools,
  fetchzip,
}:
let
  pname = "gitbutler";
  version = "0.14.35";

  src = fetchzip {
    url = "https://releases.gitbutler.com/releases/release/0.14.35-2122/linux/x86_64/GitButler_0.14.35_amd64.AppImage.tar.gz";
    hash = "sha256-ksY2ZgJyKLcSva1TAtiO0DuhpW8BzaPV7REjGaqCw9Q=";
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
