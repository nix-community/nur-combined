{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "unifont-psf";
  version = "17.0.05";

  src = fetchurl {
    url = "https://unifoundry.com/pub/unifont/unifont-${version}/font-builds/Unifont-APL8x16-${version}.psf.gz";
    sha256 = "sha256-9oRbtymsIoRTmJJbk5MkabMqJc+UUMBxaDgIt7jbb9Y=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 $src $out/share/fonts/Unifont-psf.psf.gz
    runHook postInstall
  '';

  meta = {
    description = "A specialized PSF 1 console frame buffer font consisting of 512 glyphs for use with APL, A Programming Language, in console mode (single-user mode on GNU/Linux, etc.), mainly to support GNU APL";
    homepage = "https://unifoundry.com/unifont/index.html";

    license = with lib.licenses; [
      gpl2Plus
      fontException
    ];
    platforms = lib.platforms.all;
  };
}
