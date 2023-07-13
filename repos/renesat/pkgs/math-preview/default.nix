{ nodejs, fetchFromGitLab, pkgs, stdenv, lib
}:

let
  version = "5.1.1";

  src = fetchFromGitLab {
  owner = "matsievskiysv";
  repo = "math-preview";
  rev = "v${version}";
  hash = "sha256-P3TZ/D6D2PvwPV6alSrDEQujzgI8DhK4VOuCC0BCIFo=";
};

  myNodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

in myNodePackages.package.override {
  inherit version src;

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  meta = with lib; {
    description = "Emacs preview math inline";
    license = licenses.gpl3Plus;
    homepage = "https://gitlab.com/matsievskiysv/math-preview";
    maintainers = with maintainers; [ renesat ];
    platforms = platforms.unix ++ platforms.windows;
  };
}
