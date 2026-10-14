{
  stdenv, lib, fetchFromGitHub,
  meson, ninja, pkgconfig,
  zlib, ispc,
  protobuf, protobufc, gtest,
  buildBackends ? true,
  useCUDA ? false, cudatoolkit ? null, cudnn ? null,
  useOpenCL ? false, opencl-headers ? null, ocl-icd ? null,
  useOpenBLAS ? false, openblas ? null, eigen ? null, python3 ? null

, nix-update-script
}:
let
  pname = "lc0";
  version = "0.29.0";
  optionals = lib.optionals;
in

assert buildBackends -> useCUDA || useOpenBLAS || useOpenCL;
assert useCUDA -> cudatoolkit != null && cudnn != null;
assert (useOpenBLAS || useOpenCL) -> openblas != null;
assert useOpenCL -> opencl-headers != null && ocl-icd != null;

stdenv.mkDerivation {
  inherit pname version;
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "LeelaChessZero";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-VUTUTYvvE2kGhL1EDmidV2J4/NcNcJb3oh81jsYJyfo=";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig
    zlib
    protobuf protobufc ispc gtest
    #cudnn cudatoolkit
    eigen
    openblas
    python3
    ocl-icd opencl-headers
  ];

  mesonFlags = [
    "-Dbuild_backends=${if buildBackends then "true" else "false"}"
    "-Dcudnn=false"
    "-Dplain_cuda=false"
    "-Ddx=false"
#    "-Dispc=false"
#    "-Dblas=false"
    "-Dmetal=disabled"
    "-Dopencl=true"
    "-Dopencl_libdirs=${ocl-icd}/lib"
    "-Dopencl_include=${opencl-headers}/include"
  ];

  doCheck = gtest != null;
  checkPhase = ''
    for test in /build/source/build/*_test
    do
      $test
    done
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = ''
      Lc0 is a UCI-compliant chess engine designed to play chess via neural
      network, specifically those of the LeelaChessZero project.
    '';
    homepage = "https://lczero.org/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ synthetica ];
    platforms = platforms.linux;
    broken = useCUDA;
  };
}
