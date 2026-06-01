{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "stltostp_git";
  version = "unstable-2025-11-27";

  src = fetchFromGitHub {
    owner = "slugdev";
    repo = "stltostp";
    rev = "b22cfbda0cfb79add475ec66939e6eb714e00082";
    sha256 = "1hpx15jc0hp4likvqnnh93wmh1d1q0vm60izi1m63fgxm7grkcb2";
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
