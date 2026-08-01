{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "stltostp";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "slugdev";
    repo = "stltostp";
    rev = "v${version}";
    hash = "sha256-ITC4Z4Cck3KE4pMHNVfxLUJ9utyzpH2TvqsbyLSU/jk=";
  };



  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Command line utility to convert stl files to STEP brep files";
    homepage = "https://github.com/slugdev/stltostp";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [ ];
    mainProgram = "stltostp";
  };
}
