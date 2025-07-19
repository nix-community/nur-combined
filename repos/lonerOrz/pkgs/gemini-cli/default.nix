{
  lib,
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
    rev = "v${finalAttrs.version}";
    hash = "sha256-egQlKqS5pD1mIZChmT2LLnrDq8U+5RbvLNDNhkd5vhE=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-tzVmMiHP24qKDJZYHLmGZpFZ2Y4uExassO3v3syrl2s=";
  };

  preBuild = ''
    mkdir -p packages/cli/src/generated
    # The TypeScript source file
    echo "export const GIT_COMMIT_INFO = { commitHash: '${finalAttrs.src.rev}' };" > packages/cli/src/generated/git-commit.ts
    # The TypeScript declaration file to satisfy the strict compiler
    echo "export const GIT_COMMIT_INFO: { commitHash: string };" > packages/cli/src/generated/git-commit.d.ts
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/gemini-cli}

    cp -r node_modules $out/share/gemini-cli/

    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli
    rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core
    cp -r packages/cli $out/share/gemini-cli/node_modules/@google/gemini-cli
    cp -r packages/core $out/share/gemini-cli/node_modules/@google/gemini-cli-core

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
    broken = true;
  };
})
