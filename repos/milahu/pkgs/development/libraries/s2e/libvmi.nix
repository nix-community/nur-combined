{ lib
, llvmPackages
, s2e
, cmake
, pkg-config
, libdwarf
, rapidjson
, libllvm
, libxml2
, libffi
, libelf
, zstd
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-libvmi";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd libvmi
    substituteInPlace CMakeLists.txt \
      --replace-fail 'libdwarf.a' 'libdwarf.so' \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libllvm
    libdwarf
    rapidjson
    libxml2
    libffi
    # fix: /build/source/libvmi/include/vmi/ELFFile.h:27:10: fatal error: 'libelf.h' file not found
    libelf
    # fix: /nix/store/0gi4vbw1qfjncdl95a9ply43ymd6aprm-binutils-2.40/bin/ld: cannot find -lzstd: No such file or directory
    zstd
  ];
}
