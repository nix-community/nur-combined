{
  sources,
  rustPlatform,
  lib,
}:

rustPlatform.buildRustPackage {
  inherit (sources.otf2psf) pname version src;
  cargoLock = sources.otf2psf.cargoLock."Cargo.lock";

  meta = with lib; {
    homepage = "https://github.com/pcarrin2/otf2psf";
    description = "Convert an OTF/TTF font into a Linux-TTY-compatible PSF2 font";
    license = licenses.unlicense;
    maintainers = with maintainers; [ yinfeng ];
  };
}
