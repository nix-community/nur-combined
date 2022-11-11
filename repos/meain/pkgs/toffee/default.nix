{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "toffee";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-L2w7NAMasRZ/MM0AqHkPE4OmbEQ4KKtHuhKvJTX51kI=";
  };

  cargoSha256 = "sha256-UJikH+IcuRCHAYOOr1Wf1YSutQAlybzuJzl/6JjGFpQ=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/toffee";
    description = "Universal test runner";
    license = licenses.asl20;
  };
}
