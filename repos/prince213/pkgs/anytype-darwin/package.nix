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
  version = "0.54.11";

  src =
    {
      aarch64-darwin = fetchurl {
        url = "https://github.com/anyproto/anytype-ts/releases/download/v${finalAttrs.version}/Anytype-${finalAttrs.version}-mac-arm64.zip";
        hash = "sha256-AYE7ZRoTfAczeFAgAjIgIxdiTSwZ1BLfQn/atRld8Yg=";
      };
      x86_64-darwin = fetchurl {
        url = "https://github.com/anyproto/anytype-ts/releases/download/v${finalAttrs.version}/Anytype-${finalAttrs.version}-mac-x64.zip";
        hash = "sha256-r2nGengsowsKS3JK0Y5F9AEkFCfL0tNChSuqrvAZP0A=";
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
