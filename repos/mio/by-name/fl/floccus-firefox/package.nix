{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  zip,
}:

buildNpmPackage (finalAttrs: {
  pname = "floccus-firefox";
  version = "5.12.0";

  extid = "floccus@handmadeideas.org";

  src = fetchFromGitHub {
    owner = "floccusaddon";
    repo = "floccus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DAA8eelnfoQAuJlEg93w73K7m74kvda90AsENxgRi5w=";
  };

  nodejs = nodejs_22;

  npmDepsHash = "sha256-vJIz35o3hchhyiZEf8IAHT6/F5CbGDvRvMROz2J8aqk=";

  nativeBuildInputs = [ zip ];

  # The default `gulp` target also runs Capacitor mobile sync, which we skip.
  buildPhase = ''
    runHook preBuild
    npx gulp build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    work="$TMPDIR/floccus-firefox"
    mkdir -p "$work"

    cp -r dist "$work/"
    cp -r icons "$work/"
    cp -r lib "$work/"
    cp -r _locales "$work/"
    cp LICENSE.txt PRIVACY_POLICY.md README.md "$work/"
    cp manifest.firefox.json "$work/manifest.json"

    pushd "$work" > /dev/null
    zip -qr "$TMPDIR/floccus.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/floccus.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/floccus.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/floccusaddon/floccus/releases/tag/v${finalAttrs.version}";
    description = "floccus bookmarks sync Firefox add-on built from source";
    homepage = "https://floccus.org";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})
