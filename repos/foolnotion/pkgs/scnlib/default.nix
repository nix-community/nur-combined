{ lib
, stdenv
, fetchFromGitHub
, cmake
, fast-float
, enableShared ? !stdenv.hostPlatform.isStatic

, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "scnlib";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "eliaskosunen";
    repo = "scnlib";
    rev = "v${version}";
    sha256 = "sha256-qEZAWhtvhKMkh7fk1yD17ErWGCpztEs0seV4AkBOy1I=";
  };

  nativeBuildInputs = [ cmake ];
  # fast-float is linked PRIVATE by scnlib's CMake; when scnlib is built
  # static, CMake does not propagate PRIVATE link deps to consumers via the
  # exported target, so it must be propagated ourselves in that case.
  buildInputs = lib.optionals enableShared [ fast-float ];
  propagatedBuildInputs = lib.optionals (!enableShared) [ fast-float ];

  cmakeFlags = [
    "-DSCN_TESTS=OFF"
    "-DSCN_EXAMPLES=OFF"
    "-DSCN_BENCHMARKS=OFF"
    "-DSCN_BENCHMARKS_BUILDTIME=OFF"
    "-DSCN_BENCHMARKS_BINARYSIZE=OFF"
    "-DSCN_USE_EXTERNAL_BENCHMARK=ON"
    "-DSCN_USE_EXTERNAL_FAST_FLOAT=ON"
    "-DSCN_INSTALL=ON"
    "-DBUILD_SHARED_LIBS=${if enableShared then "ON" else "OFF"}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Modern C++ library for replacing scanf and std::istream";
    homepage = "https://scnlib.readthedocs.io/";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
