{
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "firejail-profiles";
  version = "0-unstable-20250114";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/etc/firejail"
    install -Dm644 ${./adobe-acrobat-reader.profile} \
      "$out/etc/firejail/adobe-acrobat-reader.profile"
    install -Dm644 ${./notepad++.profile} \
      "$out/etc/firejail/notepad++.profile"

    runHook postInstall
  '';

  meta = {
    description = "Firejail profiles for packages in this repository";
    homepage = "https://firejail.wordpress.com/";
    license = lib.licenses.unfreeRedistributable or lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
})
