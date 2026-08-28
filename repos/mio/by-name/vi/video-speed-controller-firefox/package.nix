{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "video-speed-controller-firefox";
  version = "0.6.3.3";

  extid = "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}";

  src = fetchFromGitHub {
    owner = "codebicycle";
    repo = "videospeed";
    rev = "firefox-port";
    hash = "sha256-PrOb/4HDiVE3eI8cpcgrwKT74RR/ZXMHCl4/IBZc510=";
  };

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    pushd . > /dev/null
    zip -qr "$TMPDIR/video-speed-controller.xpi" \
      manifest.json \
      icons \
      inject.css \
      inject.js \
      options.css \
      options.html \
      options.js \
      popup.css \
      popup.html \
      popup.js \
      shadow.css
    popd > /dev/null

    install -Dm644 "$TMPDIR/video-speed-controller.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/video-speed-controller.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    description = "Video Speed Controller Firefox add-on built from source";
    homepage = "https://github.com/codebicycle/videospeed";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
