{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "toffee";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-+ZPV8LGXzv0IYuH6uJnIMfueA0aCuwltNyropHzqrqk=";
  };

  cargoSha256 = "sha256-gD/ysJystYliDjAEC2Ex3cjw31aWpGma8MTCNjJAoTQ=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/toffee";
    description = "Universal test runner";
    license = licenses.asl20;
  };
}
