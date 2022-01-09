{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "toffee";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-rY0WH+nC6LXNj08894uYX+wqKrvv9fuwa82LdneEdlE=";
  };

  cargoSha256 = "sha256-QH326F87XaRqctiNGKoF07jna3prr7lTQ47YKi1pp6I=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/toffee";
    description = "Universal test runner";
    license = licenses.asl20;
  };
}
