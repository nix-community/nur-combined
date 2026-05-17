{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "FunctionalPlus";
  version = "0.2.28";

  src = fetchFromGitHub {
    owner = "Dobiasd";
    repo = "FunctionalPlus";
    rev = "v${version}";
    hash = "sha256-cXZGiiuxrsYic3PMLj4F7fTPfTsWugChrFqrzI6cLt4=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Functional Programming Library for C++";
    homepage = "https://github.com/Dobiasd/FunctionalPlus";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
