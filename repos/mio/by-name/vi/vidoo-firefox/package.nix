{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vidoo-firefox";
  version = "1.1.3";

  extid = "{9bb36814-9543-496e-9013-5b7938e1f589}";

  src = fetchFromGitHub {
    owner = "geraked";
    repo = "vidoo";
    rev = "c9c00995cd8d8b54d85cd8c6ba279abc3ac40755";
    hash = "sha256-F0EYlu9a5ENiGWsclKF+cCzHOqbSyG8ES0LvKul0G+U=";
  };

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    pushd . > /dev/null
    zip -qr "$TMPDIR/vidoo.xpi" manifest.json icons scripts
    popd > /dev/null

    install -Dm644 "$TMPDIR/vidoo.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/vidoo.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    description = "Vidoo Firefox add-on built from source";
    homepage = "https://github.com/geraked/vidoo";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
