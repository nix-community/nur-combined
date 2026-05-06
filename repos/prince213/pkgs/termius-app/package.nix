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
      version = "9.37.6";
      src = fetchurl {
        url = "https://web.archive.org/web/20260418063434if_/https://autoupdate.termius.com/mac-arm64/Termius.zip";
        hash = "sha256-rk0Ur61wf+CqIO0rj8ePi5Pzk7UiczFk4D1kTLkqA7U=";
      };
    };
    x86_64-darwin = {
      version = "9.37.6";
      src = fetchurl {
        url = "https://web.archive.org/web/20260418063453if_/https://autoupdate.termius.com/mac/Termius.zip";
        hash = "sha256-h/oPVhj4j7grL6hA81Y9xuJYdD8ORdqcgmxZoHPTLUE=";
      };
    };
    x86_64-linux = {
      version = "9.38.1";
      src = fetchurl {
        url = "https://web.archive.org/web/20260506110927if_/https://deb.termius.com/pool/main/t/termius-app/termius-app_9.38.1_amd64.deb";
        hash = "sha256-4GZcXe4pz/6GLzWf2zWExk+3GbMVwsopd49K9ApQtVc=";
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
