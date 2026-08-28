{
  lib,
  stdenvNoCC,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yt-mirror-firefox";
  version = "1.3.2";

  extid = "yt-mirror@nurpkgs.local";

  src = ./extension;

  nativeBuildInputs = [ zip ];

  installPhase = ''
    runHook preInstall

    pushd $src > /dev/null
    zip -qr "$TMPDIR/yt-mirror.xpi" .
    popd > /dev/null

    install -Dm644 "$TMPDIR/yt-mirror.xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/yt-mirror.xpi"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    description = "YT Mirror Firefox add-on — horizontally flip YouTube videos and Shorts (ported from Chrome)";
    homepage = "https://chromewebstore.google.com/detail/yt-mirror/nokjcgeafjfhlbclmmgfeiiebgjfollb";
    license = lib.licenses.unfreeRedistributable;
    platforms = lib.platforms.all;
  };
})
