{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  yarn-berry_4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clock-weather-card";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "pkissling";
    repo = "clock-weather-card";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CZ9tRHBrVP1EV8JgH9pYIYxnGCWNvCDftL2t5lURI0o=";
  };

  missingHashes = ./missing-hashes.json;

  # Upstream's lockfile checksum for @formatjs/intl-utils@3.8.4 does not match the
  # npm tarball; use the one yarn-berry-fetcher computes. Shared with the fetcher
  # because yarnBerryConfigHook compares both lockfiles.
  postPatch = ''
    substituteInPlace yarn.lock --replace-fail \
      '10c0/737d5e796c46da0efc956a31a73a754e4e368fa1d7d7190a6c5a10192f6bab93569437a3165669fb0d435f6f054e0651f30e511f3d14bab467fd79384d0e2062' \
      '10c0/b6afae90723c109f52940b3740be4833441373596a17f73b34c6f681da0e688dbfc97513b3d0a1f22c568d3f08b29ff90e49244f18ff9d30c29999c319b1cec5'
  '';

  offlineCache = yarn-berry_4.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes postPatch;
    hash = "sha256-Pp7fNLBhL9XZXIIVvQA4ZMsMdmS7ADXnp8bLuvuiJlI=";
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

  # The entrypoint imports hashed chunks from the same directory; Home Assistant's
  # lovelace module dir is flat, so install every bundle (minus precompressed copies).
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    find dist -maxdepth 1 -type f ! -name '*.gz' -exec cp -t $out {} +

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Home Assistant Card indicating today's date/time, along with an iOS inspired weather forecast for the next days with animated icons";
    homepage = "https://github.com/pkissling/clock-weather-card";
    changelog = "https://github.com/pkissling/clock-weather-card/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ mrene ];
    platforms = platforms.linux;
  };
})
