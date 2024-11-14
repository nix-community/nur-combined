{ stdenv
, fetchFromGitHub
, lib
, zig_0_12
}:

stdenv.mkDerivation rec {
  pname   = "love-you-mom";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "love-you-mom";
    rev   = version;
    hash  = "sha256-XRPi0FEkjaUVYOXbYjhwf0acANiLZ5pybQiFnpV09m4=";
  };

  nativeBuildInputs = [ zig_0_12.hook ];

  # Enables heavy optimizations.
  zigBuildFlags = [ "-Doptimize=ReleaseFast" ];

  meta = with lib; {
    description = "Tells your mom (or dad) that you love them";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/love-you-mom";
    license     = licenses.gpl3Plus;
    mainProgram = pname;
  };
}
