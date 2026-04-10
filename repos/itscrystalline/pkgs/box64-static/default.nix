{
  box64,
  mold-unwrapped,
  libc,
  lib,
}:
box64.overrideAttrs (prev: {
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'ASMFLAGS  -pipe -mcpu=cortex-a76' 'ASMFLAGS  -pipe -march=armv8.2-a+fp16+dotprod' \
      --replace-fail 'set(CMAKE_EXE_LINKER_FLAGS -static)' 'set(CMAKE_EXE_LINKER_FLAGS "-static -L${libc.static}/lib")'
  '';
  nativeBuildInputs = prev.nativeBuildInputs ++ [mold-unwrapped];
  cmakeFlags =
    prev.cmakeFlags
    ++ [
      (lib.cmakeBool "WITH_MOLD" true)
      (lib.cmakeBool "STATICBUILD" true)
    ];
})
