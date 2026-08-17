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
    platforms = lib.attrNames sources;
  };

  sources = lib.fromJSON (lib.readFile ./sources.json);

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";
  source = sources.${stdenvNoCC.hostPlatform.system} or throwSystem;
  src = fetchurl source.src or throwSystem;
in
if stdenvNoCC.hostPlatform.isDarwin then
  import ./darwin.nix {
    inherit pname meta;
    inherit (source) version;
    inherit src;

    inherit
      stdenvNoCC
      unzip
      ;
  }
else
  import ./linux.nix {
    inherit pname meta;
    inherit (source) version;
    inherit src;

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
