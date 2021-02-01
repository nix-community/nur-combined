{ lib, stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  name = "cntr-${version}";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "cntr";
    rev = version;
    sha256 = "0lmbsnjia44h4rskqkv9yc7xb6f3qjgbg8kcr9zqnr7ivr5fjcxg";
  };

  cargoSha256 = "12r1dpapxal0r93805ixhv05x45dc2ml6yqdsqa15xpdpg6il5am";

  meta = with lib; {
    description = "A container debugging tool based on FUSE";
    homepage = "https://github.com/Mic92/cntr";
    license = licenses.mit;
  };
}
