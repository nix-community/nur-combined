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
  pname = "termius-app";

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
    aarch64-darwin = {
      version = "9.39.0";
      src = fetchurl {
        url = "https://web.archive.org/web/20260607035904if_/https://autoupdate.termius.com/mac-arm64/Termius.zip";
        hash = "sha256-rdIO8ce73tN2GSZDoRq7yvh6c6U8GH67YfZnnBMyQBY=";
      };
    };
    x86_64-darwin = {
      version = "9.39.0";
      src = fetchurl {
        url = "https://web.archive.org/web/20260607035958if_/https://autoupdate.termius.com/mac/Termius.zip";
        hash = "sha256-KUGaHxKahMDuK7DyrlEHi3hLnwoFWphRbS41bWdnZNM=";
      };
    };
    x86_64-linux = {
      version = "9.39.0";
      src = fetchurl {
        url = "https://web.archive.org/web/20260607035727if_/https://deb.termius.com/pool/main/t/termius-app/termius-app_9.39.0_amd64.deb";
        hash = "sha256-k2/Fo6vXvlXIbMpyi8/lXEk8z5gVWpsik+mY6xH4uZo=";
      };
    };
  };

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";
  source = sources.${stdenvNoCC.hostPlatform.system} or throwSystem;
in
if stdenvNoCC.hostPlatform.isDarwin then
  import ./darwin.nix {
    inherit pname meta;
    inherit (source) version src;

    inherit
      stdenvNoCC
      unzip
      ;
  }
else
  import ./linux.nix {
    inherit pname meta;
    inherit (source) version src;

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
