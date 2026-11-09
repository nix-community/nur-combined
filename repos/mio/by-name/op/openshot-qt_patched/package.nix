{
  openshot-qt,
}:

let
  libopenshot_patched = openshot-qt.passthru.libopenshot.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail "set(CMAKE_CXX_STANDARD 17)" "set(CMAKE_CXX_STANDARD 20)"
      substituteInPlace src/effects/AnalogTape.cpp \
        --replace-fail "float lerp(" "float unused_fn(" \
        --replace-fail "lerp(" "std::lerp("
      substituteInPlace src/effects/DenoiseImage.cpp \
        --replace-fail "float lerp(" "float unused_fn(" \
        --replace-fail "lerp(" "std::lerp("
      substituteInPlace src/effects/FilmGrain.cpp \
        --replace-fail "float lerp(" "float unused_fn(" \
        --replace-fail "lerp(" "std::lerp("
    '';
  });
in
openshot-qt.override {
  libopenshot = libopenshot_patched;
}
