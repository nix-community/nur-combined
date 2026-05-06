{
  anytype,
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
}:
let
  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (anytype) pname;
  version = "0.55.4";

  src =
    {
      aarch64-darwin = fetchurl {
        url = "https://github.com/anyproto/anytype-ts/releases/download/v${finalAttrs.version}/Anytype-${finalAttrs.version}-mac-arm64.zip";
        hash = "sha256-YN2J4+V+lNcKjA63YbLBp26kTql1hdxEHDTkBae5NfI=";
      };
      x86_64-darwin = fetchurl {
        url = "https://github.com/anyproto/anytype-ts/releases/download/v${finalAttrs.version}/Anytype-${finalAttrs.version}-mac-x64.zip";
        hash = "sha256-SvbeBUcSkpFwU80tx23dG3KrMw/G/zsvrMqJxKfPhwo=";
      };
    }
    .${stdenvNoCC.hostPlatform.system} or throwSystem;

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R Anytype.app $out/Applications

    runHook postInstall
  '';

  meta = anytype.meta // {
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.platforms.darwin;
    broken = false;
  };
})
