{
  lib,
  clangStdenv,
  fetchFromGitHub,
  cmake,
}:

# this project only officially supports clang
clangStdenv.mkDerivation rec {
  pname = "xenonrecomp";
  version = "0-unstable-2025-08-04";

  src = fetchFromGitHub {
    owner = "hedge-dev";
    repo = "XenonRecomp";
    rev = "ddd128bcca99fe8bfbb99bea583c972351fa6ace";
    hash = "sha256-suzrnFuHlDrrUWx70jJBNOJwgLpWasBrdqeth//PfWc=";
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
    platforms = platforms.x86;
  };
}
