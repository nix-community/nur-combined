{ lib, stdenv, fetchFromGitHub, premake5, glfw, openal, libX11, libXrandr, mpg123, libsndfile }:

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
  pname = "re3";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "GTAmodding";
    repo = "re3";
    rev = "a3964dfd4a6d84aded126f0314498b0da0aaf93a";
    sha256 = "07aam7hjpcbjicjdik8qzn97r5zvn592c31q4lvx018vk8q43w8k";
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
    install -Dm755 ../bin/linux-amd64-librw_gl3_glfw-oal/Release/re3 $out/bin/re3
    mkdir -p $out/share/games/re3
    cp -r ../gamefiles $out/share/games/re3
  '';
  meta = with lib; {
    description = "GTA III engine";
    license = licenses.unfree;
    homepage = src.meta.homepage;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
