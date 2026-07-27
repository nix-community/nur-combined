{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  bun,
  makeBinaryWrapper,
  lib,
}: let
  version = "0.4.0-unstable-2026-02-20";
  rev = "e93c758e91c1ea375bbbdd7682eb40c07adcf5d1";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "portless";
    inherit version;

    src = fetchFromGitHub {
      owner = "vercel-labs";
      repo = "portless";
      inherit rev;
      hash = "sha256-JWxhm5sdLKW2Ps91S91xpuxasMI56oEQGLTCIN4uoPY=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-dn3obG12jm7VnqbJVp6MVerAHwTmNzdq0xIl+Ehy0I0=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      bun
      makeBinaryWrapper
    ];

    pnpmInstallFlags = ["--ignore-scripts"];

    buildPhase = ''
      runHook preBuild

      bun build ./packages/portless/src/cli.ts --outfile build/cli.js --target node --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/portless $out/bin

      cp build/cli.js $out/share/portless/cli.js
      makeWrapper ${lib.getExe nodejs} $out/bin/portless \
        --add-flags "$out/share/portless/cli.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Replace port numbers with stable, named .localhost URLs";
      homepage = "https://github.com/vercel-labs/portless";
      license = licenses.asl20;
      maintainers = [];
      platforms = platforms.unix;
      mainProgram = "portless";
    };
  })
