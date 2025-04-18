{
  fetchFromGitHub,
  llvmPackages_19,
  kdePackages,
  boost183,
  tinyxml,
  stdenv,
  catch2,
  sqlite,
  gtest,
  cmake,
  ninja,
  jdk23,
  maven,
}:

stdenv.mkDerivation rec {
  pname = "sourcetrail";
  version = "2025.3.3";

  nativeBuildInputs = [
    kdePackages.wrapQtAppsHook
    catch2
    gtest
    cmake
    ninja
    jdk23
    maven
  ];

  buildInputs = [
    llvmPackages_19.clang-unwrapped.dev
    kdePackages.qtbase
    kdePackages.qtsvg
    boost183
    sqlite
    tinyxml
  ];

  src = fetchFromGitHub {
    owner = "petermost";
    repo = "Sourcetrail";
    rev = version;
    hash = "sha256-JP+m6p1LT9N9aCZHYVhPY2G16uKQRqLybl2qbfMtyzw=";
  };

  cmakeFlags = [
    "--preset"
    "system-ninja-release"
  ];
}
