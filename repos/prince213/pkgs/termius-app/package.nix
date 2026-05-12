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
      version = "9.38.2";
      src = fetchurl {
        url = "https://web.archive.org/web/20260512024846if_/https://autoupdate.termius.com/mac-arm64/Termius.zip";
        hash = "sha256-UDJ3LBR1VVvh14N2OjapUh7y3I+6j9P8uhdx0Ks6nK4=";
      };
    };
    x86_64-darwin = {
      version = "9.38.2";
      src = fetchurl {
        url = "https://web.archive.org/web/20260512024930if_/https://autoupdate.termius.com/mac/Termius.zip";
        hash = "sha256-2f29BgNDuDkvv41Qorppuxs5gc6y5e//p7p8G8OzsKU=";
      };
    };
    x86_64-linux = {
      version = "9.38.2";
      src = fetchurl {
        url = "https://web.archive.org/web/20260512025125if_/https://deb.termius.com/pool/main/t/termius-app/termius-app_9.38.2_amd64.deb";
        hash = "sha256-pXmUtkBhMd54J2vrYvm75Q1up82N9TPunmd9X2VuUpU=";
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
