{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  replaceVars,
  cmake,
  boost,
  jre,
}:

let
  json_src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "nlohmann_json_cmake_fetchcontent";
    tag = "v3.9.1";
    hash = "sha256-5A18zFqbgDc99pqQUPcpwHi89WXb8YVR9VEwO18jH2I=";
  };
  antlr_src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "antlr4";
    rev = "remove-pthread";
    hash = "sha256-ohhj59+rBZBUvL9exURx4BHgeM+zUUvvcHkdh8hJLw0=";
  };
  antlr_jar = fetchurl {
    url = "http://www.antlr.org/download/antlr-4.11.1-complete.jar";
    hash = "sha256-YpdeGStK8mIrcrXwExVT7jy86X923CpBYy3MVeJUc+E=";
  };
  kgt_src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "kgt";
    rev = "56c3f46cf286051096d9295118c048219fe0d776";
    hash = "sha256-xH0htDZd2UihLn7PHKLjEYETzcBSeJFOMNredTqlCW8=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "diagon";
  version = "1.1.158";

  src = fetchFromGitHub {
    owner = "ArthurSonzogni";
    repo = "Diagon";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Qxk3+1T0IPmvB5v3jaqvBnESpss6L8bvoW+R1l5RXdQ=";
  };

  patches = [
    # Prevent CMake from trying to fetch libraries from GitHub
    (replaceVars ./deps.patch {
      inherit
        antlr_src
        antlr_jar
        json_src
        kgt_src
        ;
    })
  ];

  nativeBuildInputs = [
    cmake
    jre
  ];

  buildInputs = [ boost ];

  cmakeFlags = [ (lib.cmakeBool "DIAGON_BUILD_TESTS" finalAttrs.doCheck) ];

  doCheck = false;

  postCheck = ''
    ./input_output_test
  '';

  meta = {
    description = "Interactive ASCII art diagram generators";
    homepage = "https://github.com/ArthurSonzogni/Diagon";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    skip.ci = true;
  };
})
