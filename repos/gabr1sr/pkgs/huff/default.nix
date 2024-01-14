{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "huff";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "huff-language";
    repo = "huff-rs";
    rev = "813b6b683dd214dfca71d49284afd885dd9eef09";
    sha256 = "1p679340dd777xn0gy3w7jrw7dy7c4m0jg5vzikrdi88bvrslbay";
  };

  doCheck = false;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = {
    description = "A low-level assembly language for the Ethereum Virtual Machine built in blazing-fast pure rust. ";
    homepage = "https://github.com/huff-language/huff-rs";
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
    license = lib.licenses.asl20;
  };
}
