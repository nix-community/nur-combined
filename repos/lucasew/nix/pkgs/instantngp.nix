{ stdenv
, lib
, cmake
, cudatoolkit
, zlib
, gnumake
, fetchFromGitHub
, addOpenGLRunpath
, python3Packages
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

  TCNN_CUDA_ARCHITECTURES = 37; # K80

  patchPhase = ''
    substituteInPlace src/common.cu \
      --replace 'fs::path get_executable_dir() {' "fs::path get_executable_dir() { return \"$src\";"
  '';

  cmakeFlags = [ "-DNGP_BUILD_WITH_GUI=OFF" ];

  nativeBuildInputs = [ cmake cudatoolkit addOpenGLRunpath ];

  enableParallelBuilding = true;

  buildInputs = [ zlib python3Packages.python ];

  installPhase = ''
    mkdir -p $out/{bin,lib,include,${python3Packages.python.sitePackages}}
    install -m 755 instant-ngp $out/bin
    install -m 755 *.a *.so $out/lib
    install -m 755 *.h $out/include
    mv $out/lib/*cpython* $out/${python3Packages.python.sitePackages}
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    addOpenGLRunpath $out/bin/instant-ngp
  '';
}
