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
    cp -rv ${./profiles}/* "$out/etc/firejail/"

    runHook postInstall
  '';

  meta = {
    description = "Firejail profiles for packages in this repository";
    homepage = "https://firejail.wordpress.com/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
