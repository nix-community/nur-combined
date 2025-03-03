{
  lib,
  clangStdenv,
  fetchFromGitHub,
  cmake,
}:

# this project only officially supports clang
clangStdenv.mkDerivation rec {
  pname = "xenonrecomp";
  version = "0-unstable-2025-02-26";

  src = fetchFromGitHub {
    owner = "hedge-dev";
    repo = "XenonRecomp";
    rev = "04e716178b397d11b7eb52be4cd27b0e99cd559d";
    hash = "sha256-pjpvK7vWCm0MwYKWiKhGWqRAIGfNPOerpvOnzm+e1hw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  # the original installPhase, for some reason, puts libfmt stuff
  # and not the actual XenonRecomp files?!?
  installPhase = ''
    mkdir -p $out/bin
    for f in Xenon{Analyse,Recomp}; do
      cp $f/$f $out/bin/$f
    done
  '';

  meta = with lib; {
    description = "A tool for recompiling Xbox 360 games to native executables.";
    homepage = "https://github.com/hedge-dev/XenonRecomp";
    license = licenses.mit;
    platforms = platforms.all;
    broken = with clangStdenv; !(isx86_64 || isx86_32);
  };
}
