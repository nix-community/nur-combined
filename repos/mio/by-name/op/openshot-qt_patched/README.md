# openshot-qt_patched

Patched `openshot-qt` package from Nixpkgs.

## Build issue in upstream Nixpkgs

In nixos-unstable with GCC 16, `libopenshot` fails to compile because:
1. `CMakeLists.txt` hardcoded `set(CMAKE_CXX_STANDARD 17)`. With GCC 16, libstdc++ headers enable `__cpp_lib_three_way_comparison`, triggering Abseil comparison headers used by Protobuf to require C++20 features (`std::partial_ordering`).
2. When upgraded to C++20 standard, `lerp` helper functions in `src/effects/AnalogTape.cpp`, `src/effects/DenoiseImage.cpp`, and `src/effects/FilmGrain.cpp` collide with `std::lerp` in `<cmath>`.

## Fix

1. Upgrade `CMAKE_CXX_STANDARD` to 20 in `libopenshot`.
2. Use `std::lerp` in `AnalogTape.cpp`, `DenoiseImage.cpp`, and `FilmGrain.cpp`.
3. Pass patched `libopenshot` into `openshot-qt`.
