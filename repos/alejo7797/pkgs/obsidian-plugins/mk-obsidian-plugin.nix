{
  lib,
  stdenv,
  obsidian,
  jq,
  nodejs,
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  extendDrvArgs =
    finalAttrs:
    attrs@{ nativeBuildInputs ? [ ], ... }:
    {
      name = "obsidian-" + attrs.name or "${finalAttrs.pname}-${finalAttrs.version}";

      strictDeps = true;
      nativeBuildInputs = nativeBuildInputs ++ [ nodejs ];

      npmBuildScript = "build";

      doCheck = true;
      nativeCheckInputs = [ jq ];

      checkPhase = ''
        [[ $(jq -r < manifest.json '.minAppVersion') == ${attrs.minObsidianVersion} ]]
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 -t $out main.js manifest.json styles.css
        runHook postInstall
      '';

      meta = (attrs.meta or { }) // {
        platforms = attrs.meta.platforms or obsidian.meta.platforms;
        broken = attrs.meta.broken or lib.versionOlder obsidian.version attrs.minObsidianVersion;
      };
    };
}
