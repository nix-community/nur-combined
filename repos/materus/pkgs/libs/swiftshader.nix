{ pkgs, lib, stdenv, fetchFromGitHub, cmake, python3 }:


stdenv.mkDerivation rec {
  pname = "swiftshader";
  version = "03102023";
  src = fetchFromGitHub {
    owner = "google";
    repo = "SwiftShader";
    rev = "400ac3a175a658d8157f8a363271ae7ab013c2ee";
    sha256 = "sha256-t3XjGPY6CutpyIKolUjvprOkJjKCEfDmU7+x1Hmzpfg=";
    fetchSubmodules = true;
  };

  buildInputs = [ cmake python3 ];

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/share/vulkan/icd.d
    install -Dm755 libvk_swiftshader.so $out/lib
    install -Dm644 Linux/vk_swiftshader_icd.json  $out/share/vulkan/icd.d

    sed -i "s#./libvk_swiftshader.so#$out/lib/libvk_swiftshader.so#" $out/share/vulkan/icd.d/vk_swiftshader_icd.json
  '';


  meta = with lib; {
    description = "SwiftShader is a high-performance CPU-based implementation of the Vulkan 1.3 graphics API";
    homepage = "https://swiftshader.googlesource.com/SwiftShader";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
