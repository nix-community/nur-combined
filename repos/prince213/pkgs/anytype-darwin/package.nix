{
  anytype,
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
}:
let
  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";

  sources = lib.fromJSON (lib.readFile ./sources.json);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (anytype) pname;
  inherit (sources) version;
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl sources.${stdenvNoCC.hostPlatform.system} or throwSystem;

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
