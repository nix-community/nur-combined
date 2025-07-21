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
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "${finalAttrs.version}";
    hash = "sha256-iyIrfsyhCii9Y5IEwj+xmgvqyFjlhDWG2tN6Q1tX/lY=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-Zm3PtIiLNEHqP09YR9+OBp2NdrtU8FxIteEh46zTVuE=";
  };

  patches = [ ./gemini.path ];

  postPatch = ''
    mkdir -p packages/cli/src/generated

    echo "export const GIT_COMMIT_INFO = '${finalAttrs.src.rev}';" > packages/cli/src/generated/git-commit.js
    echo "export const GIT_COMMIT_INFO: string;" > packages/cli/src/generated/git-commit.d.ts

    echo "===== GENERATED FILES ====="
    ls -l packages/cli/src/generated
    echo "==========================="
  '';

  nativeBuildInputs = [
    nodejs
    git
  ];

  buildPhase = ''
    npm run build
  '';

  dontNpmBuild = true;

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

    # https://github.com/NixOS/nixpkgs/pull/421992
    # When attempting to update the package of this project using the Nix package manager, the build fails.
    # This is because Nix's build process is heavily sandboxed and relies on fixed-output derivations.
    # It requires the integrity hash to verify package contents and the resolved URL to fetch them deterministically,
    # disallowing any unexpected network access during the build phase.
    # The previous package-lock.json was missing these fields for several dependencies since 0.1.7.
    # broken = true;
  };
})
