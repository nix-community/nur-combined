{
  lib,
  bashInteractive,
  buildNpmPackage,
  bubblewrap,
  fetchurl,
  jq,
  makeSetupHook,
  makeWrapper,
  nodejs,
  pkgs,
  runCommand,
  stdenv,
  versionCheckHook,
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
