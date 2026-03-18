{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "cpp-lazy";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "MarcDirven";
    repo = "cpp-lazy";
    rev = "v${version}";
    hash = "sha256-tNEAbQs3fHXp+nUPRkIA1UoNnOlr8MZHBwyZlP19Nyg=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCPP-LAZY_USE_STANDALONE=ON"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A fast C++11/14/17/20 header only library for lazy evaluation and function tools";
    homepage = "https://github.com/MarcDirven/cpp-lazy";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
