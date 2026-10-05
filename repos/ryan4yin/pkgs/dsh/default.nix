{
  lib,
  bashInteractive,
  buildNpmPackage,
  bubblewrap,
  fetchurl,
  jq,
  makeSetupHook,
  makeWrapper,
  mkUpdateScript,
  nodejs,
  pkgs,
  runCommand,
  stdenv,
  versionCheckHook,
  writeText,
}:

let
  versionData = lib.importJSON ./hashes.json;
  inherit (versionData) version;

  # dsh touches $DSH_HOME (~/.dsh) even for `--version`, so the install
  # check needs a writable HOME. nixpkgs has no such hook; llm-agents.nix
  # ships its own, inlined here.
  versionCheckHomeHook = makeSetupHook {
    name = "version-check-home-hook";
  } ./version-check-home.sh;

  # dsh's plugin manager (`dsh plugin`, profile installs) shells out to a
  # `pnpm` on PATH, and the profile workspaces it generates carry no
  # `packageManager` pin. Upstream develops and tests against the pnpm
  # pinned in its own package.json, so ship that exact version instead of
  # the (newer) nixpkgs pnpm. Bump together with the dsh version.
  pnpmPinned = pkgs.callPackage (pkgs.path + "/pkgs/development/tools/pnpm/generic.nix") {
    version = "11.7.0";
    hash = "sha256-3q+n7JihIYtqBHKJuS++I5XB4i00lbtxFlMBMhjuFe4=";
  };

  # The prebuilt node-addon-require-builtin probes V8 getter machine code and
  # fails on nixpkgs' nodejs builds (the zerocallusedregs hardening flag
  # changes the codegen the pattern matcher expects; nixpkgs#565667, still
  # open). dsh-app-boot calls the addon unconditionally at boot, so without a
  # fix the CLI cannot start on NixOS at all. The wrapper already runs node
  # with --expose-internals, under which internal modules are requirable
  # directly, so replace the addon entry with that fallback.
  requireBuiltinShim = writeText "require-builtin-shim.js" ''
    "use strict";
    // Nix-specific shim replacing the native probe (see package.nix).
    const { createRequire } = require("node:module");
    const nodeRequire = createRequire(__filename);
    const requireBuiltin = (moduleId) => nodeRequire(moduleId);
    const isAllowedInternalId = () => true;
    const getBindingInfo = () => ({ backend: "shim" });
    exports.requireBuiltin = requireBuiltin;
    exports.isAllowedInternalId = isAllowedInternalId;
    exports.getBindingInfo = getBindingInfo;
    exports.default = { requireBuiltin, isAllowedInternalId, getBindingInfo };
  '';

  # The npm tarball ships no lockfile. Ours is generated without
  # devDependencies (they reference unpublished workspace packages), so
  # drop them from the manifest too.
  srcWithLock = runCommand "dsh-source" { nativeBuildInputs = [ jq ]; } ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${version}.tgz";
        hash = versionData.sourceHash;
      }
    } -C $out --strip-components=1
    jq 'del(.devDependencies)' $out/package.json > $out/package.json.tmp
    mv $out/package.json.tmp $out/package.json
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
buildNpmPackage {
  pname = "dsh";
  inherit version;
  src = srcWithLock;

  npmDepsFetcherVersion = 2;
  npmDepsHash = versionData.npmDepsHash;

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    # Replace the native require-builtin probe with the --expose-internals
    # fallback (see requireBuiltinShim above). The grep guard fails the build
    # if upstream ever changes the addon entry shape.
    addonEntry=$out/lib/node_modules/@deepseek-ai/dsh/node_modules/node-addon-require-builtin/lib/index.js
    grep -q createEntryApi "$addonEntry"
    install -m644 ${requireBuiltinShim} "$addonEntry"

    # /bin/bash does not exist on NixOS: the persistent-bash terminal's
    # DEFAULT_BASH_SHELL literal. The non-interactive `bash` tool resolves
    # `bash` through PATH instead, which the wrapper below provides.
    substituteInPlace \
      $out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-terminal-bash/lib/index.js \
      --replace-fail '"/bin/bash"' '"${lib.getExe bashInteractive}"'

    rm $out/bin/dsh
    makeWrapper ${lib.getExe nodejs} $out/bin/dsh \
      --argv0 dsh \
      --add-flags "--expose-internals" \
      --add-flags "$out/lib/node_modules/@deepseek-ai/dsh/lib/bin.js" \
      --prefix PATH : ${
        lib.makeBinPath (
          [
            bashInteractive # the non-interactive `bash` tool
            pnpmPinned # dsh plugin / profile installs
          ]
          ++ lib.optionals stdenv.hostPlatform.isLinux [ bubblewrap ]
        )
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    versionCheckHomeHook
  ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = mkUpdateScript {
    name = "dsh";
    extraRuntimeInputs = [ nodejs ];
  };

  meta = {
    description = "Open-source agent harness developed by DeepSeek AI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    changelog = "https://github.com/deepseek-ai/deepseek-harness/releases";
    downloadPage = "https://www.npmjs.com/package/@deepseek-ai/dsh";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      fromSource
    ];
    mainProgram = "dsh";
    platforms = lib.platforms.all;
  };
}
