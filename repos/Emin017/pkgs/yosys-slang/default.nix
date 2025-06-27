{
  lib,
  stdenv,
  fetchgit,
  yosys,
  cmake,
}:
stdenv.mkDerivation rec {
  pname = "yosys-slang";
  version = "0-unstable-2025-06-21";
  plugin = "slang";

  src = fetchgit {
    url = "https://github.com/povik/yosys-slang.git";
    rev = "76b83eb5b73ba871797e6db7bc5fed10af380be4";
    sha256 = "sha256-xXL2Kpv95ot++kBWta0XF8HzboW0MmPOxT5sxmyKYgA=";
    fetchSubmodules = true;
  };

  cmakeFlags = [
    "-DBUILD_AS_PLUGIN=ON"
    "-DYOSYS_PLUGIN_DIR=${placeholder "out"}/share/yosys/plugins"
    "-DYOSYS_SLANG_REVISION=${src.rev or "unknown"}"
    "-DSLANG_REVISION=unknown"
  ];

  patches = [
    ./fix-install-path-and-revision.patch
  ];

  buildInputs = [
    yosys
  ];

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "SystemVerilog frontend for Yosys ";
    homepage = "https://github.com/povik/yosys-slang";
    license = lib.licenses.isc;
  };
}
