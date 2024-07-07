{ lib
, fetchFromGitHub
, buildRustPackage
}:

buildRustPackage rec {
  pname = "chunkdrive";
  version = "2023-08-12";

  src = fetchFromGitHub {
    owner = "C10udburst";
    repo = "chunkdrive";
    rev = "142c0c7e75ebbea10485cb2796d93d34448566b3";
    sha256 = "sha256-lrM6OLyZbTUvoW1rS3kJVPP69uaM216uGVTGQGdsLaM=";
  };

  cargoSha256 = "sha256-1xZj6iuEpViZdr6NQG/d5nBYNDA0JtFtw7qFfr5wOL8=";
  verifyCargoDeps = true;

  meta = with lib; {
    description = "Check if tables and items in a .toml file are lexically sorted";
    homepage = "https://github.com/devinr528/cargo-sort-ck";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
