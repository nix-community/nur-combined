{ lib, clang12Stdenv, fetchFromGitHub, cmake, ninja, vulkan-headers, vulkan-loader, gtk3, libsecret, libgcrypt, systemd, freeglut, nasm }:

clang12Stdenv.mkDerivation rec{
  pname = "cemu-wiiu";
  version = "2.0";
  
  src = fetchFromGitHub {
    owner = "cemu-project";
    repo = "Cemu";
    rev = "v${version}";
    sha256 = "5DgG+EgKLXtLWS1u01j8GM8c+h5Uv/l/dS3x/t4qIW4=";
    fetchSubmodules = true;
  };
  
  nativeBuildInputs = [ cmake ninja ];
  
  cmakeFlags = [
    "-G Ninja"
    "-DCMAKE_BUILD_TYPE=release"
    "-DCMAKE_MAKE_PROGRAM=${ninja}/bin/ninja"
  ];
  
  buildInputs = [ vulkan-headers vulkan-loader gtk3 libsecret libgcrypt systemd freeglut nasm ];
  
 meta = with lib; {
  description = "Cemu is a Wii U emulator";
  homepage = "https://cemu.info";
  license = licenses.mpl20;
  platforms = platforms.linux;
 }; 
}