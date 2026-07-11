{
  lib,
  stdenv,
  stdenvNoCC,
  symlinkJoin,
  linkFarm,
  copyPathToStore,
  fetchFromGitHub,
  fetchgit,
  fetchurl,
  runCommandLocal,
  writeShellApplication,
  makeSetupHook,
  bun,
  yq-go,
  libarchive,
  autoPatchelfHook,
  zig_0_15,
  patch,
}:

let
  src = ../../vendor/bun2nix;
  cacheEntryCreatorSrc = ../../vendor/bun2nix/programs/cache-entry-creator;

  bunWithNode =
    { useFakeNode ? true, ... }:
    if useFakeNode then
      stdenvNoCC.mkDerivation {
        name = "bun-with-fake-node";
        dontUnpack = true;
        dontBuild = true;

        installPhase = ''
          cp -r "${bun}/." "$out"
          chmod u+w "$out/bin"

          for node_binary in "node" "npm" "npx"; do
            ln -s "$out/bin/bun" "$out/bin/$node_binary"
          done
        '';
      }
    else
      symlinkJoin {
        name = "bun-with-real-node";
        paths = [ bun ];
      };

  extractPackage = writeShellApplication {
    name = "extract-bun-package";
    runtimeInputs = [ libarchive ];
    text = ''
      throw_usage () {
          echo "Missing required flags"
          echo "Usage: --pkg <pkg> --out <out>"
          exit 1
      }

      pkg=""
      out=""

      while [ "$#" -gt 0 ]; do
        case "$1" in
          --package)
            shift
            pkg="$1"
            ;;
          --out)
            shift
            out="$1"
            ;;
          --package=* )
            pkg="''${1#--package=}"
            ;;
          --out=* )
            out="''${1#--out=}"
            ;;
          -*)
            echo "Unknown option: $1"
            throw_usage
            ;;
          *)
            echo "Unexpected positional arg: $1"
            throw_usage
            ;;
        esac
        shift
      done

      if [ -z "$pkg" ] || [ -z "$out" ]; then
        throw_usage
      fi

      mkdir -p "$out"

      if [[ "$pkg" = *.tgz ]]; then
        bsdtar --extract \
          --file "$pkg" \
          --directory "$out" \
          --strip-components=1 \
          --no-same-owner \
          --no-same-permissions
      else
        cp -r "$pkg/." "$out"
      fi

      chmod -R u+rwx "$out"
    '';
  };

  cacheEntryCreator = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "bun2nix-cache-entry-creator";
    version = "2.1.0";

    src = cacheEntryCreatorSrc;
    nativeBuildInputs = [ zig_0_15.hook ];

    postConfigure = ''
      ln -s ${import (cacheEntryCreatorSrc + "/deps.nix") { inherit linkFarm fetchgit; }} $ZIG_GLOBAL_CACHE_DIR/p
    '';

    zigBuildFlags = [ "--release=fast" ];

    meta.mainProgram = "cache_entry_creator";
  });

  extractHost =
    url:
    let
      match = builtins.match "https?://([^/]+).*" url;
    in
    if match != null then builtins.elemAt match 0 else null;

  extractScope =
    name:
    if lib.hasPrefix "@" name then
      let
        match = builtins.match "(@[^/]+)/.*" name;
      in
      if match != null then builtins.elemAt match 0 else null
    else
      null;

  extractUrl = cfg: if builtins.isString cfg then cfg else cfg.url or null;

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

  buildPackage =
    {
      patchShebangs ? true,
      autoPatchElf ? false,
      nativeBuildInputs ? [ ],
      bunfigPath ? null,
      ...
    }@args:
    let
      bunWithNodePkg = bunWithNode args;
      scopeRegistries = parseScopeRegistries bunfigPath;
    in
    name: pkg:
    let
      scope = extractScope name;
      registryFromScope = if scope != null then scopeRegistries.${scope} or null else null;
      pkgUrl = pkg.passthru.url or null;
      registryFromUrl =
        if pkgUrl != null then
          let
            host = extractHost pkgUrl;
          in
          if host != null && host != "registry.npmjs.org" then host else null
        else
          null;
      registryHost = if registryFromScope != null then registryFromScope else registryFromUrl;
    in
    stdenv.mkDerivation {
      name = "bun-pkg-${name}";

      nativeBuildInputs = [
        bunWithNodePkg
      ]
      ++ lib.optionals autoPatchElf [
        autoPatchelfHook
        stdenv.cc.cc.lib
      ]
      ++ nativeBuildInputs;

      phases = [
        "extractPhase"
        "patchPhase"
        "cacheEntryPhase"
      ];

      extractPhase = ''
        runHook preExtract

        "${lib.getExe extractPackage}" \
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

        "${lib.getExe cacheEntryCreator}" \
          --out "$out/share/bun-cache" \
          --name "${name}" \
          --package "$out/share/bun-packages/${name}" \
          ${lib.optionalString (registryHost != null) "--registry \"${registryHost}\""}

        runHook postCacheEntry
      '';

      preferLocalBuild = true;
      allowSubstitutes = false;
    };

  overridePackage =
    { overrides ? { }, ... }:
    let
      preExtractPackage =
        name: pkg:
        runCommandLocal "pre-extract-${name}" { } ''
          "${lib.getExe extractPackage}" \
            --package "${pkg}" \
            --out "$out"
        '';

      overridePkg = name: pkg: overrides.${name} (preExtractPackage name pkg);
    in
    name: pkg: if overrides ? "${name}" then overridePkg name pkg else pkg;

  parseBunfigCredentials =
    bunfigPath:
    if bunfigPath != null && builtins.pathExists bunfigPath then
      let
        bunfig = builtins.fromTOML (builtins.readFile bunfigPath);
        scopes = bunfig.install.scopes or { };
        extractToken = cfg: if builtins.isString cfg then null else cfg.token or null;
        scopeEntries = builtins.mapAttrs (_: cfg: {
          url = extractUrl cfg;
          token = extractToken cfg;
        }) scopes;
      in
      builtins.listToAttrs (
        builtins.filter (x: x.value != null) (
          builtins.map (
            name:
            let
              entry = scopeEntries.${name};
            in
            {
              name = entry.url;
              value = entry.token;
            }
          ) (builtins.attrNames scopeEntries)
        )
      )
    else
      { };

  parseNpmrcCredentials =
    npmrcPath:
    if npmrcPath != null && builtins.pathExists npmrcPath then
      let
        content = builtins.readFile npmrcPath;
        lines = builtins.filter builtins.isString (builtins.split "\n" content);
        parseLine =
          line:
          let
            match = builtins.match "^//([^/]+)/:_authToken=(.+)$" line;
          in
          if match != null then
            {
              url = "https://${builtins.elemAt match 0}";
              token = builtins.elemAt match 1;
            }
          else
            null;
        parsed = builtins.filter (x: x != null) (builtins.map parseLine lines);
      in
      builtins.listToAttrs (
        builtins.map (entry: {
          name = entry.url;
          value = entry.token;
        }) parsed
      )
    else
      { };

  getAuthHeader =
    credentials: url:
    let
      match = builtins.match "https?://([^/]+)/.*" url;
      host = if match != null then builtins.elemAt match 0 else null;
      matchingUrls = builtins.filter (
        credUrl:
        let
          credMatch = builtins.match "https?://([^/]+).*" credUrl;
        in
        credMatch != null && builtins.elemAt credMatch 0 == host
      ) (builtins.attrNames credentials);
    in
    if builtins.length matchingUrls > 0 then credentials.${builtins.elemAt matchingUrls 0} else null;

  makeRegistryFetchurl =
    {
      bunfigPath ? null,
      npmrcPath ? null,
    }:
    let
      credentials = parseBunfigCredentials bunfigPath // parseNpmrcCredentials npmrcPath;
    in
    { url, ... }@args:
    let
      token = getAuthHeader credentials url;
      authArgs =
        if token != null then
          {
            curlOptsList = [
              "-H"
              "Authorization: Bearer ${token}"
            ];
          }
        else
          { };
      drv = fetchurl (args // authArgs);
    in
    drv
    // {
      passthru = (drv.passthru or { }) // {
        inherit url;
      };
    };

  fetchBunDeps =
    {
      bunNix,
      bunfigPath ? null,
      npmrcPath ? null,
      overrides ? { },
      ...
    }@args:
    let
      attrIsBunPkg = _: value: lib.isDerivation value || lib.isStorePath value;
      withErrCtx = builtins.addErrorContext ''
        Your supplied bun.nix dependencies file failed to evaluate.
      '' (
        import bunNix {
          inherit copyPathToStore fetchFromGitHub fetchgit;
          fetchurl = makeRegistryFetchurl {
            inherit bunfigPath npmrcPath;
          };
        }
      );
      packages = lib.filterAttrs attrIsBunPkg withErrCtx;
      buildPackage' = buildPackage args;
      overridePackage' = overridePackage args;
    in
    assert lib.asserts.assertEachOneOf "overrides" (builtins.attrNames overrides) (
      builtins.attrNames packages
    );
    assert lib.assertMsg (builtins.all builtins.isFunction (builtins.attrValues overrides))
      "All attr values of `overrides` must be functions.";
    symlinkJoin {
      name = "bun-cache";
      paths = lib.pipe packages [
        (builtins.mapAttrs overridePackage')
        (builtins.mapAttrs buildPackage')
        builtins.attrValues
      ];
    };

  patchedDependenciesToOverrides =
    { patchedDependencies ? { } }:
    lib.mapAttrs (
      name: patchFile:
      let
        safePatchFile = builtins.path {
          path = patchFile;
          name = lib.pipe patchFile [
            toString
            baseNameOf
            lib.strings.sanitizeDerivationName
            builtins.unsafeDiscardStringContext
          ];
        };
      in
      pkg:
      runCommandLocal "patched-${lib.strings.sanitizeDerivationName name}"
        { nativeBuildInputs = [ patch ]; }
        ''
          mkdir $out
          cp -r ${pkg}/. $out
          chmod -R u+w $out

          echo "Applying patch for ${name}..."
          patch -p1 -d $out < ${safePatchFile}
        ''
    ) patchedDependencies;

  hook = makeSetupHook {
    name = "bun2nix-hook";
    propagatedBuildInputs = [
      (writeShellApplication {
        name = "bun2nix";
        text = "";
      })
      bun
      yq-go
    ];
    substitutions = {
      resolveCatalogTs = "${src}/nix/mk-derivation/resolve-catalog.ts";
      bunDefaultInstallFlags =
        if stdenv.hostPlatform.isDarwin then
          [
            "--linker=isolated"
            "--backend=symlink"
          ]
        else
          [ "--linker=isolated" ];
    };
  } "${src}/nix/mk-derivation/hook.sh";
in
stdenvNoCC.mkDerivation {
  pname = "bun2nix-shim";
  version = "2.1.0";
  dontUnpack = true;
  dontBuild = true;
  installPhase = "mkdir -p $out";

  passthru = {
    inherit hook fetchBunDeps patchedDependenciesToOverrides;
  };

  meta = {
    description = "Local shim for bun2nix build helpers";
    homepage = "https://github.com/nix-community/bun2nix";
    license = lib.licenses.mit;
  };
}
