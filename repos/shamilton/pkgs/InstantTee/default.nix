{ lib
, fetchFromGitHub
, buildRustPackage
}:

buildRustPackage rec {
  pname = "InstantTee";
  version = "2021-04-30";

  src = fetchFromGitHub {
    owner = "ArniDagur";
    repo = "InstantTee";
    rev = "8e2b2756ac29f06eca97a6a64e0d92c1bd6380ec";
    sha256 = "1lp9jkajjkfwbdd27mrhr8zdiw9k9nh30r0j4053n2ghbyal9mcw";
  };

  cargoSha256 = "09vgdjrc9djg0mlilgr2wcj6kmbgxmdm3d2rqdy8q7b27418rrm3";
  verifyCargoDeps = true;

  meta = with lib; {
    description = "Check if tables and items in a .toml file are lexically sorted";
    homepage = "https://github.com/devinr528/cargo-sort-ck";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
