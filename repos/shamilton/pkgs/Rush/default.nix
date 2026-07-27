{ lib
, stdenv
, fetchFromGitHub
# , nix-gitignore
, meson
, ninja
, pkg-config
, cmake
, sfml
, cxxopts
}:

stdenv.mkDerivation {
  pname = "Rush";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Rush";
    rev = "ffe0fe1dcff9bac1354ae90b725c173d725efe85";
    sha256 = "sha256-bL5X2CNQQEzYJw3G8MLTHkpGi462pHuOkdLjMkrKKA8=";
  };
  # src = nix-gitignore.gitignoreSource [ ] ~/GIT/Rush;

  nativeBuildInputs = [ pkg-config ninja meson cmake ];

  buildInputs = [
    sfml
    cxxopts
  ];
  # NIX_CFLAGS_COMPILE = "-g -O0";
  # hardeningDisable = [ "all" ]; 
  # dontStrip = true;

  mesonFlags = [ "-Dassetdir=${placeholder "out"}/share/assets" ];

  meta = with lib; {
    description = "A web service to access rpi-fan data";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/rpi-fan-serve";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
