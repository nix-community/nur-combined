{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "homescript";
  version = "0-unstable-2026-03-05";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "homescript-dev";
    repo = "server";
    rev = "687a29f266e2e233bcf437adaeacea52cd46a532";
    hash = "sha256-XeGc17OlEPuYyZWr4u1KYVFH+UIODh1fVhbKmAONxAs=";
  };

  vendorHash = "sha256-6LsHT66cYqirOfl8bf2hmEZVypnYBHQuazjNO3lhfJg=";

  postInstall = ''
    mv $out/bin/{,homescript-}server
  '';

  meta = {
    description = "Homescript Server";
    homepage = "https://github.com/homescript-dev/server";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
