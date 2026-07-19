{
  lib,
  stdenv,
  fetchzip,
  runCommand,
  fetchNpmDeps,
  npmHooks,
  nodejs_22,
  jq,
  zip,
}:

let
  version = "6.1.6";

  upstreamSrc = fetchzip {
    url = "https://github.com/ajayyy/SponsorBlock/releases/download/${version}/SourceCodeUseThisOne.zip";
    hash = "sha256-gby1WGY1MMpOXoeifNdaqVb9BDSquhM2cWKC1Z9dnlw=";
    stripRoot = false;
  };

  src = runCommand "sponsorblock-for-youtube-${version}-source" { nativeBuildInputs = [ jq ]; } ''
    cp -r ${upstreamSrc} $out
    chmod -R u+w $out
    jq -f ${./fix-package-lock.jq} "$out/package-lock.json" > "$out/package-lock.json.tmp"
    mv "$out/package-lock.json.tmp" "$out/package-lock.json"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sponsorblock-for-youtube-firefox";
  inherit version src;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-YNfWlPR2YWAbDBWzdTX3cqbZL0wqMaif2G9Im5vx8zg=";
  };

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    zip
  ];

  makeCacheWritable = true;
  npmFlags = [ "--ignore-scripts" ];

  postPatch = ''
    cp config.json.example config.json
  '';

  buildPhase = ''
    runHook preBuild

    npm run build:firefox

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pushd dist > /dev/null
    zip -qr "$TMPDIR/sponsorblock.xpi" *
    popd > /dev/null

    install -Dm644 "$TMPDIR/sponsorblock.xpi" "$out/sponsorBlocker@ajay.app.xpi"
    ln -s sponsorBlocker@ajay.app.xpi "$out/sponsorblock.xpi"

    runHook postInstall
  '';

  passthru = {
    extid = "sponsorBlocker@ajay.app";
  };

  meta = {
    description = "SponsorBlock for YouTube Firefox add-on built from source";
    homepage = "https://github.com/ajayyy/SponsorBlock";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
