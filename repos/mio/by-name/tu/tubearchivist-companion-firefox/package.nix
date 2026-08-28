{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tubearchivist-companion-firefox";
  version = "0.5.0";

  extid = "{08f0f80f-2b26-4809-9267-287a5bdda2da}";

  src = fetchFromGitHub {
    owner = "tubearchivist";
    repo = "browser-extension";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aPaC9IdwWB0Txp270/pv9nQ3RU9ws+dZI4Gi4p/SE4s=";
  };

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    work="$TMPDIR/tubearchivist-companion"
    mkdir -p "$work"
    cp -r extension/. "$work/"
    cp "$work/manifest-firefox.json" "$work/manifest.json"

    pushd "$work" > /dev/null
    zip -qr "$TMPDIR/tubearchivist-companion.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/tubearchivist-companion.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/tubearchivist-companion.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/tubearchivist/browser-extension/releases/tag/v${finalAttrs.version}";
    description = "TubeArchivist Companion Firefox add-on built from source";
    homepage = "https://github.com/tubearchivist/browser-extension";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
