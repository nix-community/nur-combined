{ stdenv
, lib
, cmake
, cudatoolkit
, zlib
, gnumake
, fetchFromGitHub
, addOpenGLRunpath
, python3
}:

stdenv.mkDerivation {
  pname = "instantngp";
  version = "2023.04.14-unstable";

  src = fetchFromGitHub {
    owner = "NVlabs";
    repo = "instant-ngp";
    rev = "e45134b9bcf50d0c04f27bc3ab3cde57c27f5bc8";
    hash = "sha256-/FAjfmw7GmV7svaFaAQrPXJlfckMM0e1k6aKlJP99V8=";
    fetchSubmodules = true;
    deepClone = true;
  };

  cmakeFlags = [ "-DNGP_BUILD_WITH_GUI=OFF" ];

  nativeBuildInputs = [ cmake cudatoolkit addOpenGLRunpath ];

  enableParallelBuilding = true;

  buildInputs = [ zlib python3 ];

  installPhase = ''
    mkdir -p $out/{bin,lib,include}
    install -m 755 instant-ngp $out/bin
    install -m 755 *.a *.so $out/lib
    install -m 755 *.h $out/include
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    addOpenGLRunpath $out/bin/instant-ngp
  '';
}
