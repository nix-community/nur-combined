{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "tessil-robin-map";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "Tessil";
    repo = "robin-map";
    rev = "v${version}";
    sha256 = "sha256-jCkwwpAQj+mlZ81g+3H4w1Ofw4O6NZqDwVeGO5e+J7Q=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "C++ implementation of a fast hash map and hash set using open-addressing and linear robin hood hashing with backward shift deletion to resolve collisions.";
    homepage = "https://github.com/Tessil/robin-map";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
