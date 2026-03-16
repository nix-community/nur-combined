{
  bun,
  fetchFromGitHub,
  lib,
  nodejs,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    inherit (stdenvNoCC.hostPlatform) system;
    bunDeps = stdenvNoCC.mkDerivation {
      name = "${finalAttrs.pname}-bun-deps";

      inherit (finalAttrs) src;

      nativeBuildInputs = [ bun ];

      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

        bun install --production --no-save --frozen-lockfile --no-progress

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -R node_modules $out/

        runHook postInstall
      '';

      outputHash = finalAttrs.passthru.bunDepsHashes.${system} or (throw "Unsupported system: ${system}");
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };
  in
  {
    pname = "shanghaitech-mirror-frontend";
    version = "0-unstable-2025-12-05";

    src = fetchFromGitHub {
      owner = "ShanghaitechGeekPie";
      repo = "shanghaitech-mirror-frontend";
      rev = "b6dfaf73463f605fa03c3dbd7a1cad8abfe7fd23";
      hash = "sha256-dO+ZIDLE9ABUEm4rDGfssJdXIE/3UKDYVEybuddpQ+U=";
    };

    nativeBuildInputs = [ bun ];

    postConfigure = ''
      cp -R ${bunDeps}/node_modules .
      substituteInPlace node_modules/.bin/{tsc,vite} \
        --replace-fail "/usr/bin/env node" "${lib.getExe nodejs}"
    '';

    buildPhase = ''
      runHook preBuild

      bun run --prefer-offline build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -R dist $out

      runHook postInstall
    '';

    passthru = {
      bunDepsHashes = {
        aarch64-darwin = "sha256-hxlnQ9Lob318LFqPvRDsXnzPzd3fu+euIJ2Pkqpd+qk=";
        aarch64-linux = "sha256-g0OUyRSfvxGzkW/eR3YtjkGgufopTNMqNp5BiFjPALQ=";
        x86_64-darwin = "sha256-kreD/+qP8eUPGEtlJ4G8/yOpta1CncaZuFlQsdCWG2E=";
        x86_64-linux = "sha256-zTYra2klcITr0dvdS5brIM6L0L8WfM8roIMCE96gylo=";
      };
    };

    meta = {
      description = "Frontend of the ShanghaiTech Open Source Mirror";
      homepage = "https://github.com/ShanghaitechGeekPie/shanghaitech-mirror-frontend";
      # https://github.com/zTrix/sata-license
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ prince213 ];
      platforms = lib.attrNames finalAttrs.passthru.bunDepsHashes;
    };
  }
)
