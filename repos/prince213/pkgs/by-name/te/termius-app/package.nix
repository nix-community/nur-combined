{
  lib,
  fetchurl,
  stdenvNoCC,

  # nativeBuildInputs
  autoPatchelfHook,
  dpkg,
  makeBinaryWrapper,
  unzip,

  # buildInputs
  alsa-lib,
  gtk3,
  libdrm,
  libGL,
  libgbm,
  libsecret,
  nss,
  udev,
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
      "x86_64-linux"
    ];
  };

  sources = {
    aarch64-darwin = {
      version = "9.42.2";
      src = fetchurl {
        url = "https://web.archive.org/web/20260803144818if_/https://autoupdate.termius.com/mac-arm64/Termius.zip";
        hash = "sha256-Q4FkY42Hnu7Mrdq9J614VoNhyYXu+pm22qGhvSAqZw8=";
      };
    };
    x86_64-linux = {
      version = "9.42.2";
      src = fetchurl {
        url = "https://web.archive.org/web/20260803145014if_/https://deb.termius.com/pool/main/t/termius-app/termius-app_9.42.2_amd64.deb";
        hash = "sha256-+tIVdAeVNr7aFZCjVXm6kXOxz8OFIK2Rh22sePi0n8I=";
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
      makeBinaryWrapper
      nss
      stdenvNoCC
      udev
      ;
  }
