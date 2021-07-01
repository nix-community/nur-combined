{ stdenv, fetchFromGitHub, premake5, glfw, openal, libX11, libXrandr, mpg123, libsndfile }:

let
  # attempt to call a nil value (global 'staticruntime')  
  premake = premake5.overrideDerivation (oldAttrs: rec {
    pname = "premake5";
    version = "5.0.0-alpha13";

    src = fetchFromGitHub {
      owner = "premake";
      repo = "premake-core";
      rev = "v${version}";
      sha256 = "1rcdqm60l4dgznmq8w4c008858g9jq798nfcca6l5zx74wk7kr7c";
    };
  });
in stdenv.mkDerivation {
  pname = "revc";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "GTAmodding";
    repo = "re3";
    # miami branch
    rev = "3988fec6e72a7ac7172cc5b709bd84ca963c17ba";
    sha256 = "0156r80qvdv5rscwhz6wdll0njk4z6n0axhfzxgx2z3aqhn5h9kn";
    fetchSubmodules = true;
  };

  buildInputs = [ glfw openal libX11 libXrandr mpg123 libsndfile ];
  nativeBuildInputs = [ premake ];

  preConfigure = ''
    patchShebangs printHash.sh
  '';

  buildPhase = ''
    premake5 --with-librw gmake2
    cd build
    make config=release_linux-amd64-librw_gl3_glfw-oal
  '';

  installPhase = ''
    install -Dm755 ../bin/linux-amd64-librw_gl3_glfw-oal/Release/reVC $out/bin/revc
    mkdir -p $out/share/games/revc
    cp -r ../gamefiles $out/share/games/revc
  '';
}
