# tsdown bundles only the CLI itself; dist/index.mjs still imports its runtime dependencies from node_modules.
{
  lib,
  stdenv,
  fetchPnpmDeps,
  makeWrapper,
  nodejs_24,
  pnpmConfigHook,
  pnpm_12,
  source,
}: let
  pname = "clash2sing-box";
  # Version the tracked HEAD commit as unstable.
  version = "0-unstable-${source.date}";

  # Cross-platform pnpm store hash refreshed by update-hashes.
  pnpmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
in
  stdenv.mkDerivation {
    inherit pname version;
    inherit (source) src;

    pnpmDeps = fetchPnpmDeps {
      inherit pname version;
      inherit (source) src;
      pnpm = pnpm_12;
      fetcherVersion = 5;
      hash = pnpmDepsHash;
    };

    nativeBuildInputs = [
      makeWrapper
      nodejs_24
      pnpm_12
      pnpmConfigHook
    ];

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      # Pruning leaves links to the removed dev dependencies behind: https://github.com/pnpm/pnpm/issues/3645
      CI=true pnpm prune --prod --ignore-scripts
      find node_modules -xtype l -delete

      mkdir -p $out/lib/clash2sing-box
      cp -r dist node_modules $out/lib/clash2sing-box/
      makeWrapper ${lib.getExe nodejs_24} $out/bin/clash2sing-box \
        --add-flags $out/lib/clash2sing-box/dist/index.mjs

      install -Dm644 LICENSE README.md -t $out/share/doc/clash2sing-box

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      # The bundle imports every runtime dependency at startup, so help alone proves they resolve.
      $out/bin/clash2sing-box convert --help | grep -qF -- '--outbound-group'

      test -f $out/share/doc/clash2sing-box/LICENSE
      test -f $out/share/doc/clash2sing-box/README.md

      runHook postInstallCheck
    '';

    meta = {
      description = "Convert Clash configurations to sing-box configurations";
      homepage = "https://github.com/MZWNET/clash2sing-box";
      license = lib.licenses.gpl3Only;
      mainProgram = "clash2sing-box";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
