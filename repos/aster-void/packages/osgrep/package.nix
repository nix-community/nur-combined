{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeBinaryWrapper,
}: let
  version = "0.5.16";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "osgrep";
    inherit version;
    dontUseCmakeConfigure = true;

    src = fetchFromGitHub {
      owner = "Ryandonofrio3";
      repo = "osgrep";
      rev = "v${version}";
      hash = "sha256-Bpk4n1G0e2TptarYxr6N4GSXDMC6Es/cg59v0HZBhIA=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-sSRRhxHcoDpVTbnsvg6rM3GQ5l7nGaMmyFmwlPNXzBo=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      makeBinaryWrapper
    ];

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      installRoot=$out/libexec/osgrep
      mkdir -p "$installRoot" $out/bin

      cp package.json pnpm-lock.yaml README.md LICENSE "$installRoot"
      cp -r dist node_modules "$installRoot"

      # drop bulky intermediate objects produced by node-gyp builds
      find "$installRoot/node_modules" -type d -name obj.target -prune -exec rm -rf {} +
      find "$installRoot/node_modules" -name '*.o' -delete

      makeWrapper ${lib.getExe nodejs} "$out/bin/osgrep" \
        --add-flags "$installRoot/dist/index.js" \
        --set NODE_ENV production

      runHook postInstall
    '';

    meta = with lib; {
      description = "Natural-language search that works like grep for AI agents and developers";
      homepage = "https://github.com/Ryandonofrio3/osgrep";
      license = licenses.asl20;
      maintainers = [];
      platforms = platforms.linux;
      mainProgram = "osgrep";
    };
  })
