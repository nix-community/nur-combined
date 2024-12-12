{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "microjson";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "semlanik";
    repo = "microjson";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6kGshpy0CDg/8z3unZvGs0Uh1gglZ7yrIGc9/X+M0i8=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'CMAKE_CXX_STANDARD 11' 'CMAKE_CXX_STANDARD 17'
    substituteInPlace tests/CMakeLists.txt \
      --replace-fail "find_package(microjson CONFIG REQUIRED)" ""
  '';

  nativeBuildInputs = [
    cmake
    gtest
  ];

  cmakeFlags = [ (lib.cmakeBool "MICROJSON_MAKE_TESTS" true) ];

  doCheck = true;

  meta = {
    description = "Tiny streaming json deserializer";
    homepage = "https://github.com/semlanik/microjson";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
