{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  lz4,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "data_tamer";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "PickNikRobotics";
    repo = "data_tamer";
    tag = finalAttrs.version;
    hash = "sha256-N9g1EB88sK2qfyl10H6xf/Nee4uHpXeNDX26VbJkzPc=";
  };

  sourceRoot = "${finalAttrs.src.name}/data_tamer_cpp";

  postPatch = ''
    sed -i '14i #include <cstdint>' 3rdparty/mcap/include/mcap/reader.hpp
    sed -i '9i #include <cstdint>' 3rdparty/mcap/include/mcap/types.hpp
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    gtest
    lz4
    zstd
  ];

  meta = {
    description = "C++ library for Fearless Timeseries Logging";
    homepage = "https://github.com/PickNikRobotics/data_tamer";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
