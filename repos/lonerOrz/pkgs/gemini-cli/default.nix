{
  lib,
  jq,
  git,
  nodejs,
  ripgrep,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  runCommand,
  ...
}:
let
  pname = "gemini-cli";
  version = "0.9.0-nightly.20251002.0f465e88";
  srcHash = "sha256-wbG9UQ/iXMrpZrsoKCjnBwYFMkNkwz/NY3xBiKeIkQM=";
  npmDepsHash = "sha256-837AecQKPynObxhUUPd80RZuhOEAeA0sJ+BWKMv7qmk=";

  srcOrig = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${version}";
    hash = "${srcHash}";
  };

  packageLockFixed = ./package-lock.fixed.json;

  src = runCommand "src-fixed" { nativeBuildInputs = [ jq ]; } ''
    mkdir -p $out
    chmod -R u+w $out
    cp -r ${srcOrig}/* $out/
    rm -f $out/package-lock.json
    cp ${packageLockFixed} $out/package-lock.json
  '';
in
buildNpmPackage (finalAttrs: {
  inherit pname version src;

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "${npmDepsHash}";
    forceGitDeps = false;
  };

  passthru.updateScript = ./update.sh;

  postPatch = ''
    mkdir -p packages/cli/src/generated
    echo "export const GIT_COMMIT_INFO = 'v${finalAttrs.version}';" > packages/cli/src/generated/git-commit.js
    echo "export const GIT_COMMIT_INFO: string;" > packages/cli/src/generated/git-commit.d.ts
  '';

  nativeBuildInputs = [
    nodejs
    git
  ];

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  postInstall = ''
    mkdir -p $out/lib/node_modules/${pname}/node_modules/@lvce-editor/ripgrep/bin
    ln -s ${ripgrep}/bin/rg $out/lib/node_modules/${pname}/node_modules/@lvce-editor/ripgrep/bin/rg
    rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli-test-utils
    rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli-a2a-server
  '';

  buildPhase = ''
    npm run build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/gemini-cli}

    cp -r node_modules $out/share/gemini-cli/
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core
    rm -f $out/share/gemini-cli/node_modules/gemini-cli-vscode-ide-companion
    cp -r packages/cli $out/share/gemini-cli/node_modules/@google/gemini-cli
    cp -r packages/core $out/share/gemini-cli/node_modules/@google/gemini-cli-core

    mkdir -p $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/src/generated
    cp packages/cli/src/generated/git-commit.js $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/src/generated/
    cp packages/cli/src/generated/git-commit.d.ts $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/src/generated/

    ln -s $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/index.js $out/bin/gemini
    chmod +x $out/bin/gemini

    runHook postInstall
  '';

  meta = {
    description = "AI agent that brings the power of Gemini directly into your terminal";
    homepage = "https://github.com/google-gemini/gemini-cli";
    mainProgram = "gemini";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    binaryNativeCode = true;
  };
})
