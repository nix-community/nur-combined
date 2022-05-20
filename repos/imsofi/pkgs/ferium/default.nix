{ stdenv
, fetchFromGitHub
, rustc
, cargo 
, rustPlatform
, pkg-config
, lib
}:

rustPlatform.buildRustPackage rec {
  pname = "ferium";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "gorilla-devs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-x781dQpG0N6pcEuF8C1R8g6cUNIevOTUMG30ruJY9+Y=";
  };

  cargoSha256 = "sha256-/3GVCm5x8aXFgp50z3Hn9ImhWqCDAIuRAKvzSoFyAFM=";
  
  # Do not build the gui part of the package.
  buildNoDefaultFeatures = true;

  # Tests are highly impure, accessing several pages
  # directly (modrinth, cloudflare, github).
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "A CLI minecraft mod manager";
    homepage = "https://github.com/theRookieCoder/ferium";
    license = licenses.mpl20;
  };
}
