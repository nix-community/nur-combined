{
  lib,
  git,
  nodejs,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  runCommand,
  ...
}:
let
  pname = "gemini-cli";
  version = "0.1.15";
  srcHash = "sha256-J9pDSMsSh7FVPD61FFV2Aes3G/Vj1j5ULn9dOr+sglQ=";
  npmDepsHsh = "sha256-pfQ02b7j8BQzPOVk64nqpVH2ofkaR3iFDlqo+XiAN4A=";

  srcOrig = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${version}";
    hash = "${srcHash}";
  };

  packageLockFixed = ./package-lock.fixed.json;

  src = runCommand "src-fixed" { } ''
    mkdir -p $out
    chmod -R u+w $out
    cp -r ${srcOrig}/* $out/
    rm -f $out/package-lock.json
    cp ${packageLockFixed} $out/package-lock.json
  '';
in
buildNpmPackage (finallAttrs: {
  inherit pname version src;

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "${npmDepsHsh}";
  };

  passthru.updateScript = ./update.sh;

  postPatch = ''
    mkdir -p packages/cli/src/generated
    echo "export const GIT_COMMIT_INFO = 'v${finallAttrs.version}';" > packages/cli/src/generated/git-commit.js
    echo "export const GIT_COMMIT_INFO: string;" > packages/cli/src/generated/git-commit.d.ts
  '';

  nativeBuildInputs = [
    nodejs
    git
  ];

  dontNpmBuild = true;

  buildPhase = ''
    npm run build
  '';

  postInstall = ''
    rm -f $out/share/gemini-cli/node_modules/gemini-cli-vscode-ide-companion
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/gemini-cli}
    cp -r node_modules $out/share/gemini-cli/
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core
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
