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
  version = "0.55.5";
  __structuredAttrs = true;
  strictDeps = true;

  src =
    {
      aarch64-darwin = fetchurl {
        url = "https://github.com/anyproto/anytype-ts/releases/download/v${finalAttrs.version}/Anytype-${finalAttrs.version}-mac-arm64.zip";
        hash = "sha256-ZuqgxheBUECjNPbkhHlxWAQT0JDg36DT79jhFZeNgOQ=";
      };
      x86_64-darwin = fetchurl {
        url = "https://github.com/anyproto/anytype-ts/releases/download/v${finalAttrs.version}/Anytype-${finalAttrs.version}-mac-x64.zip";
        hash = "sha256-xGyoF4Y0Z/ovLrslY2icKAObIwiGJk+DHpGHDxOP6t4=";
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
