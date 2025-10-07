{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "arnis";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "louis-e";
    repo = "arnis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pZS0tXoLzQW19n2zZZEgr4C1Y45q/JEX3loetLRb/WY=";
  };

  cargoHash = "sha256-2wklCohCShRQaJACiLIYbLej4xSP70qTwMQ0iN2hSJ0=";

  checkFlags = [
    "--skip=map_transformation::translate::translator::tests::test_translate_by_vector"
  ];

  meta = {
    description = "Generate real life cities in Minecraft";
    homepage = "https://github.com/louis-e/arnis";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    broken = stdenv.hostPlatform.isLinux;
  };
})
