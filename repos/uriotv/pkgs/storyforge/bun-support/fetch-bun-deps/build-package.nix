{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;

  # Extract scope from package name (e.g., "@scope/pkg@1.0.0" -> "@scope")
  extractScope =
    name:
    if lib.hasPrefix "@" name then
      let
        match = builtins.match "(@[^/]+)/.*" name;
      in
      if match != null then builtins.elemAt match 0 else null
    else
      null;

  # Extract host from URL
  extractHost =
    url:
    let
      match = builtins.match "https?://([^/]+).*" url;
    in
    if match != null then builtins.elemAt match 0 else null;

  # Extract URL from bunfig scope config
  extractUrl = cfg: if builtins.isString cfg then cfg else cfg.url or null;

  # Parse bunfig.toml for scope -> registry host mappings
  parseScopeRegistries =
    bunfigPath:
    if bunfigPath != null && builtins.pathExists bunfigPath then
      let
        bunfig = builtins.fromTOML (builtins.readFile bunfigPath);
        scopes = bunfig.install.scopes or { };
      in
      lib.filterAttrs (_: v: v != null && v != "registry.npmjs.org") (
        builtins.mapAttrs (_: cfg: extractHost (extractUrl cfg)) scopes
      )
    else
      { };
in
{
  options.perSystem = mkPerSystemOption {
    options.fetchBunDeps.buildPackage = mkOption {
      description = ''
        If the package is a tarball, extract it,
        otherwise make a copy of the directory in $out/share/bun-packages.

        If `patchShebangs` is enabled patch all
        scripts to use bun as their executor.

        Then, produce a bun cache compatible symlink in $out/share/bun-cache.
      '';
      type = types.functionTo (types.functionTo (types.functionTo types.package));
    };
  };

  config.perSystem =
    {
      pkgs,
      config,
      self',
      ...
    }:
    {
      fetchBunDeps.buildPackage =
        {
          patchShebangs ? true,
          autoPatchElf ? false,
          nativeBuildInputs ? [ ],
          bunfigPath ? null,
          ...
        }@args:
        let
          bunWithNode = config.fetchBunDeps.bunWithNode args;
          scopeRegistries = parseScopeRegistries bunfigPath;
        in
        name: pkg:
        let
          # Try to get registry from scope configuration first
          scope = extractScope name;
          registryFromScope = if scope != null then scopeRegistries.${scope} or null else null;
          # Fall back to extracting from package URL (via passthru)
          pkgUrl = pkg.passthru.url or null;
          registryFromUrl =
            if pkgUrl != null then
              let
                host = extractHost pkgUrl;
              in
              if host != null && host != "registry.npmjs.org" then host else null
            else
              null;
          # Prefer scope config, fall back to URL
          registryHost = if registryFromScope != null then registryFromScope else registryFromUrl;
        in
        pkgs.stdenv.mkDerivation {
          name = "bun-pkg-${name}";

          nativeBuildInputs = [
            bunWithNode
          ]
          ++ lib.optionals autoPatchElf (
            with pkgs;
            [
              autoPatchelfHook
              stdenv.cc.cc.lib
            ]
          )
          ++ nativeBuildInputs;

          phases = [
            "extractPhase"
            "patchPhase"
            "cacheEntryPhase"
          ];

          extractPhase = ''
            runHook preExtract

            "${lib.getExe config.fetchBunDeps.extractPackage}" \
              --package "${pkg}" \
              --out "$out/share/bun-packages/${name}"

            runHook postExtract
          '';

          patchPhase = ''
            runHook prePatch

            ${lib.optionalString patchShebangs ''patchShebangs "$out/share/bun-packages"''}
            ${lib.optionalString autoPatchElf "runHook autoPatchelfPostFixup"}

            runHook postPatch
          '';

          cacheEntryPhase = ''
            runHook preCacheEntry

            "${lib.getExe self'.packages.cacheEntryCreator}" \
              --out "$out/share/bun-cache" \
              --name "${name}" \
              --package "$out/share/bun-packages/${name}" \
              ${lib.optionalString (registryHost != null) "--registry \"${registryHost}\""}

            runHook postCacheEntry
          '';

          preferLocalBuild = true;
          allowSubstitutes = false;
        };
    };
}
