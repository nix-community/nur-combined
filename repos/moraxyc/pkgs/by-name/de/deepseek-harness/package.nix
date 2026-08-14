{
  lib,
  formats,
  coreutils,
  jq,
  stdenvNoCC,
  linkFarm,
  makeWrapper,
  nodejs-slim,
  symlinkJoin,
  versionCheckHook,
  writeShellApplication,
  writeText,

  deepseek-harness,
  deepseek-harness-kernel,

  deepseek-harness-base,
  deepseek-harness-headless,
  deepseek-harness-web-app,

  # Extra bundles to compose in; see passthru.withPlugins.
  extraPlugins ? [ ],
  # Declarative profiles to seed on first use; see passthru.withProfiles.
  profiles ? { },
  # e.g. plugin: plugin.pname == "deepseek-harness-web-app".
  withoutPlugins ? _: false,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "deepseek-harness";
  inherit (deepseek-harness-kernel) version;

  src = null;
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    jq
    makeWrapper
  ];

  installPhase = ''
    kernelApp="${deepseek-harness-kernel}/lib/deepseek-harness"
    appDir="$out/lib/deepseek-harness"

    mkdir -p "$appDir"
    # Copy lib so the profile heal anchors at this manifest, not the kernel's.
    cp -r "$kernelApp/lib" "$appDir/lib"
    ln -s "$kernelApp/config" "$appDir/config"
    cp "$kernelApp/package.json" "$appDir/package.json"
    ln -s "${finalAttrs.passthru.nodeModules}" "$appDir/node_modules"

    jq --argjson deps '${builtins.toJSON (lib.listToAttrs finalAttrs.passthru.bundleDeps)}' \
      '.dependencies *= $deps' \
      "$appDir/package.json" > "$appDir/package.json.tmp"
    mv "$appDir/package.json.tmp" "$appDir/package.json"

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs-slim} $out/bin/dsh \
      ${
        lib.optionalString (
          finalAttrs.passthru.runtimeDeps != [ ]
        ) "--prefix PATH : ${lib.makeBinPath finalAttrs.passthru.runtimeDeps} "
      }\
      --add-flags "--expose-internals" \
      --add-flags "$appDir/lib/bin.js"

    ${lib.optionalString (profiles != { }) ''
      wrapProgram $out/bin/dsh \
        --run ${lib.escapeShellArg (lib.getExe finalAttrs.passthru.seedProfiles)}
    ''}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    officialBundles = [
      deepseek-harness-base
      deepseek-harness-headless
      deepseek-harness-web-app
    ];

    composedBundles = lib.unique (
      lib.filter (plugin: !withoutPlugins plugin) (
        finalAttrs.passthru.officialBundles
        ++ extraPlugins
        ++ lib.concatMap (profile: profile.plugins) (lib.attrValues profiles)
      )
    );

    profileTemplates = linkFarm "deepseek-harness-profiles" (
      lib.concatMapAttrs (name: profile: {
        "${name}/package.json" =
          (formats.json { }).generate
            "${lib.strings.sanitizeDerivationName "dsh-profile-${name}"}-package.json"
            {
              name = "dsh-profile-${name}";
              private = true;
              dependencies = { };
              dsh.profile.bundles = lib.unique (
                [ "@deepseek-ai/dsh-base" ]
                ++ lib.concatMap (
                  plugin:
                  plugin.passthru.dshBundles or (throw ''
                    deepseek-harness.withProfiles: ${plugin.pname or plugin.name} has no passthru.dshBundles; it is not a dsh plugin bundle package
                  '')
                ) profile.plugins
              );
            };
        "${name}/cordis.patch.yml" =
          writeText "${lib.strings.sanitizeDerivationName "dsh-profile-${name}"}-cordis.patch.yml"
            (profile.patch or "[]");
        "${name}/pnpm-workspace.yaml" =
          (formats.json { }).generate
            "${lib.strings.sanitizeDerivationName "dsh-profile-${name}"}-pnpm-workspace.yaml"
            {
              packages = [ "." ];
              nodeLinker = "hoisted";
              autoInstallPeers = false;
            };
      }) profiles
    );

    seedProfiles = writeShellApplication {
      name = "dsh-seed-profiles";
      runtimeInputs = [ coreutils ];
      inheritPath = false;
      text = ''
        home=''${DSH_HOME:-''${HOME:+$HOME/.dsh}}
        [ -n "$home" ] || exit 0

        mkdir -p "$home/profiles"
        cp \
          --dereference \
          --no-clobber \
          --no-preserve=mode \
          --recursive \
          ${lib.escapeShellArg "${finalAttrs.passthru.profileTemplates}/."} \
          "$home/profiles"
      '';
    };

    nodeModules = symlinkJoin {
      name = "deepseek-harness-node-modules";
      paths = [
        "${deepseek-harness-kernel}/lib/deepseek-harness/node_modules"
      ]
      ++ (map (plugin: "${plugin}/lib/node_modules") finalAttrs.passthru.composedBundles);
    };

    bundleDeps = lib.concatMap (
      plugin:
      map (rel: {
        name = rel;
        value = plugin.version;
      }) plugin.passthru.dshBundles
    ) finalAttrs.passthru.composedBundles;

    runtimeDeps = lib.unique (
      lib.concatLists (
        map (plugin: plugin.passthru.runtimeDeps or [ ]) finalAttrs.passthru.composedBundles
      )
    );

    dshBundles = lib.concatLists (
      [ deepseek-harness-kernel.passthru.dshBundles ]
      ++ map (plugin: plugin.passthru.dshBundles) finalAttrs.passthru.composedBundles
    );

    # pkgs.deepseek-harness.withPlugins [ pkgs.some-dsh-bundle ]
    withPlugins =
      extra:
      deepseek-harness.override {
        extraPlugins = extraPlugins ++ extra;
        inherit profiles withoutPlugins;
      };

    # pkgs.deepseek-harness.withProfiles { tui.plugins = [ pkgs.deepseek-harness-tui ]; }
    withProfiles =
      configuredProfiles:
      deepseek-harness.override {
        inherit extraPlugins withoutPlugins;
        profiles = configuredProfiles;
      };
  };

  meta = {
    description = "Open-source agent harness developed by DeepSeek AI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "dsh";
    platforms = lib.platforms.unix;
  };
})
