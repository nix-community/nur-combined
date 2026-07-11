{
  feishu,
  fetchurl,
  lib,
  stdenvNoCC,
  undmg,
}:

let
  inherit (stdenvNoCC.hostPlatform) system;

  sources = lib.fromJSON (lib.readFile ./sources.json);
  source = sources.${system} or (throw "Unsupported system: ${system}");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (feishu) pname;
  __structuredAttrs = true;
  strictDeps = true;

  inherit (source) version;
  src = fetchurl source.src;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r Lark.app $out/Applications

    runHook postInstall
  '';

  passthru.updateScript = ./update.nu;

  meta = feishu.meta // {
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.attrNames sources;
  };
})
