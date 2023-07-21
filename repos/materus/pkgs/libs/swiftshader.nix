{ pkgs, lib, stdenv, fetchFromGitHub, cmake, python3 }:


stdenv.mkDerivation rec {
  pname = "swiftshader";
  version = "20072023";
  src = fetchFromGitHub {
    owner = "google";
    repo = "SwiftShader";
    rev = "4a260c12b8c155103435a7b2b99b5227f6ce7594";
    sha256 = "sha256-WcA1EazeuRlFhIaAKgJHp+rUkCR2vqcINkTMYOgrbNI=";
    fetchSubmodules = true;
  };

  buildInputs = [ cmake python3 ];

  installPhase = ''
    mkdir -p $out/lib
    mv libvk_swiftshader.so $out/lib
  '';


  meta = with lib; {
    description = "SwiftShader is a high-performance CPU-based implementation of the Vulkan 1.3 graphics API";
    homepage = "https://swiftshader.googlesource.com/SwiftShader";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
