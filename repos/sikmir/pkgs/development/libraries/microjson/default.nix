{ lib, stdenv, fetchFromGitHub, cmake, gtest }:

stdenv.mkDerivation (finalAttrs: {
  pname = "microjson";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "semlanik";
    repo = "microjson";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6kGshpy0CDg/8z3unZvGs0Uh1gglZ7yrIGc9/X+M0i8=";
  };

  postPatch = ''
    substituteInPlace tests/CMakeLists.txt \
      --replace-fail "find_package(microjson CONFIG REQUIRED)" ""
  '';

  nativeBuildInputs = [ cmake gtest ];

  cmakeFlags = [
    (lib.cmakeBool "MICROJSON_MAKE_TESTS" true)
  ];

  doCheck = true;

  meta = with lib; {
    description = "Tiny streaming json deserializer";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
