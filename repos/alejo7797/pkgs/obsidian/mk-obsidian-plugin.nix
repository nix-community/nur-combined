{
  lib,
  stdenv,
  obsidian,
  nodejs,
  obsidianManifestCheckHook,

  namePrefix ? "obsidian-plugin-",
  outFiles ? [
    "main.js"
    "manifest.json"
    "styles.css"
  ],
}:

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  extendDrvArgs =
    finalAttrs:
    attrs@{
      manifest,
      nativeBuildInputs ? [ ],
      meta ? { },
      ...
    }:
    {
      __structuredAttrs = true;
      inherit outFiles;

      name = namePrefix + attrs.name or "${finalAttrs.pname}-${finalAttrs.version}";

      strictDeps = true;
      nativeBuildInputs = nativeBuildInputs ++ [
        nodejs
        obsidianManifestCheckHook
      ];

      prePatch = ''
        # TODO: Not needed after https://github.com/NixOS/nixpkgs/pull/487974/
        export npmDeps
      '';

      npmBuildScript = "build";

      installPhase = ''
        runHook preInstall

        for f in "''${outFiles[@]}"; do
          [[ -f "$f" ]] && install -Dm644 "$f" "$out/$f"
        done

        runHook postInstall
      '';

      doInstallCheck = true;

      meta = meta // {
        platforms = meta.platforms or obsidian.meta.platforms;
        broken = meta.broken or lib.versionOlder obsidian.version manifest.minAppVersion;
      };
    };
}
