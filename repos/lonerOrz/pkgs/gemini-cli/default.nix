{
  lib,
  git,
  nodejs,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  ...
}:
buildNpmPackage (finalAttrs: {
  pname = "gemini-cli";
  version = "0.1.14";

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-u73aqh7WnfetHj/64/HyzSR6aJXRKt0OXg3bddhhQq8=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-9T31QlffPP6+ryRVN/7t0iMo+2AgwPb6l6CkYh6839U=";
  };

  patches = [ ./gemini.path ];

  postPatch = ''
    mkdir -p packages/cli/src/generated
    echo "export const GIT_COMMIT_INFO = '${finalAttrs.src.rev}';" > packages/cli/src/generated/git-commit.js
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
