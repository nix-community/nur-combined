{
  fetchFromGitHub,
  llvmPackages_19,
  kdePackages,
  tinyxml,
  stdenv,
  catch2,
  sqlite,
  gtest,
  cmake,
  ninja,
  boost,
  jdk23,
  maven,
}:
  
stdenv.mkDerivation rec {
  pname = "sourcetrail";
  version = "2025.3.3";

  nativeBuildInputs = [
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
    boost
    sqlite
    tinyxml
  ];

  src = fetchFromGitHub {
    owner = "petermost";
    repo = "Sourcetrail";
    rev = version;
    hash = "";
  };

  cmakeFlags = [
    "--preset" "system-ninja-release"
  ];
}
