{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "ht";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "ducaale";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-0HrSQmSQ1B2xMQaaSmY8tKyzn7e5yP1oyLXojD4PdSA=";
  };

  cargoHash = "sha256-t7ShFSPeeHPkI8D1zinzYXmRxHd3nC4KMTNKuNg3EcA=";

  doCheck = false;

  meta = with lib; {
    description = "Yet another HTTPie clone";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
