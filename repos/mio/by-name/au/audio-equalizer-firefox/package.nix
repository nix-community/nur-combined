{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "audio-equalizer-firefox";
  version = "0.2.3";

  extid = "{c9019a65-6808-45ca-938f-236e21cb866d}";

  src = fetchFromGitHub {
    owner = "lunu-bounir";
    repo = "audio-equalizer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1INw57OTSMDH4nwvSIoIWjLBPAnGvHOiFf/WiSiOkCk=";
  };

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    pushd v3 > /dev/null
    zip -qr "$TMPDIR/audio-equalizer.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/audio-equalizer.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/audio-equalizer.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/lunu-bounir/audio-equalizer/releases/tag/v${finalAttrs.version}";
    description = "Audio Equalizer and Amplifier Firefox add-on — global per-frequency EQ and volume";
    homepage = "https://github.com/lunu-bounir/audio-equalizer";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})
