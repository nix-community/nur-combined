{ lib
, callPackage
, stdenv
, llvmPackages
, fetchFromGitHub
, cmake
, pkg-config
, capstone
, z3
, lua
, soci
#, googletest # missing https://github.com/google/googletest
, libdwarf
, rapidjson
, libxml2
, libffi
, libelf
, zstd
, klee
}:

let
  libvmi = callPackage ./libvmi.nix { };
  libfsigcxx = callPackage ./libfsigcxx.nix { };
  libcoroutine = callPackage ./libcoroutine.nix { };
  libq = callPackage ./libq.nix { };
in

stdenv.mkDerivation rec {
  # TODO? rename to libs2e
  pname = "s2e";
  #version = "2.0.0"; # old: 2020-01-18
  version = "unstable-2024-04-13";

  src = fetchFromGitHub {
    owner = "S2E";
    repo = "s2e";
    rev = "5814e5a39b2718e4839b06d5d70297e74c4b95f5";
    hash = "sha256-5zS2mB8cX45DdAaPFfsRUHwB//zOKMEDHjgfT9Qxq0A=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  passthru = {
    inherit
      libvmi
      libfsigcxx
      libcoroutine
      libq
    ;
  };

  buildInputs = [
    libvmi
    libfsigcxx
    libcoroutine
    libq

    cmake
    llvmPackages.libllvm
    capstone
    z3
    lua
    soci # https://github.com/SOCI/soci
    #googletest
    libdwarf
    rapidjson
    # llvm
    libxml2
    libffi
    # fix: /build/source/libvmi/include/vmi/ELFFile.h:27:10: fatal error: 'libelf.h' file not found
    libelf
    # fix: /nix/store/0gi4vbw1qfjncdl95a9ply43ymd6aprm-binutils-2.40/bin/ld: cannot find -lzstd: No such file or directory
    zstd
  ];

  dontUseCmakeConfigure = true;

  patchPhase = ''
    substituteInPlace Makefile \
      --replace-fail 'curl -f -L "$1" -o "$2"' 'echo not downloading from $1 to $2' \
      --replace-fail 'tar -zxf ' 'echo not extracting ' \
      --replace-fail 'tar -Jxf ' 'echo not extracting ' \
      --replace-fail 'unzip -qqo ' 'echo not extracting ' \
      --replace-fail 'CAPSTONE_VERSION=' 'CAPSTONE_VERSION=${capstone.version}'$'\n# ' \
      --replace-fail 'Z3_VERSION=' 'Z3_VERSION=${z3.version}'$'\n# ' \
      --replace-fail 'LUA_VERSION=' 'LUA_VERSION=${lua.version}'$'\n# ' \
      --replace-fail 'SOCI_GIT_REV=' 'SOCI_GIT_REV=${soci.src.rev}'$'\n# ' \
      --replace-fail 'RAPIDJSON_GIT_REV=' 'RAPIDJSON_GIT_REV=${rapidjson.src.rev}'$'\n# ' \
      --replace-fail 'cp $(S2E_SRC)/lua/luaconf.h ' '# cp $(S2E_SRC)/lua/luaconf.h ' \
      --replace-fail ' stamps/lua-make' ' ' \
      --replace-fail ' stamps/libdwarf-make' ' ' \
      --replace-fail ' stamps/rapidjson-make' ' ' \
      --replace-fail ' stamps/gtest-release-make' ' ' \
      --replace-fail ' stamps/llvm-release-make' ' ' \
      --replace-fail ' stamps/llvm-debug-make' ' ' \
      --replace-fail ' stamps/soci-make' ' ' \
      --replace-fail ' stamps/z3-make' ' ' \
      --replace-fail ' stamps/capstone-make' ' ' \
      --replace-fail ' stamps/libvmi-debug-install' ' ' \
      --replace-fail ' stamps/libvmi-release-install' ' ' \
      --replace-fail '--with-llvm=$(LLVM_BUILD)/llvm-release' '--with-llvm=${llvmPackages.clang}' \
      --replace-fail '--with-klee=$(S2E_BUILD)/klee-release' '--with-klee=${klee}' \
      --replace-fail '--with-libvmi=$(S2E_BUILD)/libvmi-release' '--with-libvmi=${libvmi}' \
      --replace-fail '--with-fsigc++=$(S2E_BUILD)/libfsigc++-release' '--with-fsigc++=${libfsigcxx}' \
      --replace-fail '--with-libq=$(S2E_BUILD)/libq-release' '--with-libq=${libq}' \
      --replace-fail '--with-libcoroutine=$(S2E_BUILD)/libcoroutine-release' '--with-libcoroutine=${libcoroutine}' \

    # llvm-release/bin/clang
    ln -s -v ${llvmPackages.clang} llvm-release
  '';

  # TODO build only libs2e
  buildPhase = ''
    pwd
    ls
    make stamps/libvmi-release-install
  '';

  meta = with lib; {
    description = "S2E: A platform for multi-path program analysis with selective symbolic execution";
    homepage = "https://github.com/S2E/s2e";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
