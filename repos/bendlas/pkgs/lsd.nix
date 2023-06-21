{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  name = "lsd-${version}";
  version = "0.23.1";

  src = fetchFromGitHub {
    owner = "lsd-rs";
    repo = "lsd";
    rev = "${version}";
    sha256 = "sha256-FY1odcKBl7zJ+MxfohkmC1e45fPQK3MKB3orQdCRpA4=";
  };

  cargoSha256 = "sha256-t7J7hIbLlRq99Yd2/3Zn+PbHhJtaJRdDluDXN0Hp/Jc=";

  ## FIXME error: Found argument '--test-threads' which wasn't expected, or isn't valid in this context
  doCheck = false;

  meta = with lib; {
    description = "The next gen ls command";
    homepage = https://github.com/lsd-rs/lsd;
    license = licenses.asl20;
    maintainers = [ maintainers.bendlas ];
    platforms = platforms.all;
  };
}
