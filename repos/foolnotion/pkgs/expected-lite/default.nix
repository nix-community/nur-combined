{ lib, stdenv, fetchFromGitHub, cmake 
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "expected-lite";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "martinmoene";
    repo = "expected-lite";
    rev = "v${version}";
    sha256 = "sha256-nxwdymBNbd+RuL8rKi2Fx2gC68TnJe7WnoN0O01lecQ=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A single-file header-only library for objects that either represent a valid value or an error that you can pass by value..";
    homepage = "https://github.com/martinmoene/expected-lite";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
