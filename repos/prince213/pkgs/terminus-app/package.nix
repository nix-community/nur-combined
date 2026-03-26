{
  alsa-lib,
  autoPatchelfHook,
  dpkg,
  fetchurl,
  gtk3,
  lib,
  libdrm,
  libGL,
  libgbm,
  libsecret,
  makeWrapper,
  nss,
  stdenvNoCC,
  udev,
  unzip,
}:
let
  pname = "terminus-app";
  version = "9.37.5";

  meta = {
    description = "Desktop SSH Client";
    homepage = "https://termius.com/";
    downloadPage = "https://termius.com/download";
    changelog = "https://termius.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };

  sources = {
    aarch64-darwin = fetchurl {
      url = "https://web.archive.org/web/20260324105231if_/https://autoupdate.termius.com/mac-arm64/Termius.zip";
      hash = "sha256-LZagd46XBaZvhh0zLsKwx2y0JE/iZIZEugUBqAig0U8=";
    };
    x86_64-darwin = fetchurl {
      url = "https://web.archive.org/web/20260324105323if_/https://autoupdate.termius.com/mac/Termius.zip";
      hash = "sha256-zPdQnf4zt1onOiE/zg4W+nHAlF9WghKwnI2CuPpsRtQ=";
    };
    x86_64-linux = fetchurl {
      url = "https://deb.termius.com/pool/main/t/termius-app/termius-app_9.37.5_amd64.deb";
      hash = "sha256-hOTgKHAaai1GjgE0sKIwVtvukokklquFgWkqUnN+egA=";
    };
  };

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";
  src = sources.${stdenvNoCC.hostPlatform.system} or throwSystem;
in
if stdenvNoCC.hostPlatform.isDarwin then
  import ./darwin.nix {
    inherit
      pname
      version
      src
      meta
      ;

    inherit
      stdenvNoCC
      unzip
      ;
  }
else
  import ./linux.nix {
    inherit
      pname
      version
      src
      meta
      ;

    inherit
      alsa-lib
      autoPatchelfHook
      dpkg
      gtk3
      lib
      libdrm
      libGL
      libgbm
      libsecret
      makeWrapper
      nss
      stdenvNoCC
      udev
      ;
  }
