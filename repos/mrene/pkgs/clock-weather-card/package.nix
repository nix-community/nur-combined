{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  yarn-berry_4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clock-weather-card";
  version = "2.9.3";

  src = fetchFromGitHub {
    owner = "pkissling";
    repo = "clock-weather-card";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CeOrJFdvl9O6TF9E2W34mR6VmLnTzhXGmrBmbtsBLxA=";
  };

  missingHashes = ./missing-hashes.json;

  # 1. Upstream lockfile checksum for @formatjs/intl-utils@3.8.4 does not match the
  #    zip produced from the current npm tarball, so we replace it with the actual
  #    value computed by yarn-berry-fetcher.
  # 2. Bump lockfile version 8 -> 9 so yarn 4.14 considers it current and skips
  #    the resolution refresh that would otherwise hit the registry.
  # 3. Pre-declare the v8 migration defaults so the patched offline yarn does not
  #    error trying to apply pending migrations.
  # All three fixes must apply in both derivations (yarnBerryConfigHook diffs lockfiles).
  postPatch = ''
    substituteInPlace yarn.lock \
      --replace-fail \
      '10c0/737d5e796c46da0efc956a31a73a754e4e368fa1d7d7190a6c5a10192f6bab93569437a3165669fb0d435f6f054e0651f30e511f3d14bab467fd79384d0e2062' \
      '10c0/b6afae90723c109f52940b3740be4833441373596a17f73b34c6f681da0e688dbfc97513b3d0a1f22c568d3f08b29ff90e49244f18ff9d30c29999c319b1cec5'

    substituteInPlace yarn.lock \
      --replace-fail $'__metadata:\n  version: 8' $'__metadata:\n  version: 9'

    cat >> .yarnrc.yml <<'EOF'
    approvedGitRepositories:
      - "**"
    enableScripts: true
    EOF
  '';

  offlineCache = yarn-berry_4.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes postPatch;
    hash = "sha256-BRRBCR5XNWZbs4ruukqOdp+MjLlxqya3WC3mWR4ltQw=";
  };

  nativeBuildInputs = [
    nodejs
    yarn-berry_4
    yarn-berry_4.yarnBerryConfigHook
  ];

  buildPhase = ''
    runHook preBuild

    yarn build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp dist/clock-weather-card.js $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Home Assistant Card indicating today's date/time, along with an iOS inspired weather forecast for the next days with animated icons";
    homepage = "https://github.com/pkissling/clock-weather-card";
    changelog = "https://github.com/pkissling/clock-weather-card/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ mrene ];
    platforms = platforms.linux;
  };
})
