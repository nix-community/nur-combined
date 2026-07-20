{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "stltostp";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "slugdev";
    repo = "stltostp";
    rev = "v${version}";
    sha256 = "1bqr6w5n082nj16cr6wh90n9xxiwaa2v36mmy4v8fqrif1wqf3p2";
  };

  patches = [ ./fix-build.patch ];

  prePatch = ''
    for f in main.cpp StepKernel.h StepKernel.cpp; do
      sed -i 's/\r$//' "$f"
    done
  '';

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
