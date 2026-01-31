{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "homescript";
  version = "0-unstable-2026-01-04";

  src = fetchFromGitHub {
    owner = "homescript-dev";
    repo = "server";
    rev = "444bbd48f858cb12ae8cce7cc0d63be26aee5902";
    hash = "sha256-JNEDv8OEEZ7tOlIKk2nxvIfTjrfWMT6Yp1Qi2Vn1H8Q=";
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
