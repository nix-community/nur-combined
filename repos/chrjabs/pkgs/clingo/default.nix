{
  lib,
  stdenv,
  toPythonModule,
  fetchFromGitHub,
  cmake,
  python,
  cffi,
}:
toPythonModule (
  stdenv.mkDerivation (finalAttrs: {
    pname = "clingo";
    version = "5.8.0";

    src = fetchFromGitHub {
      owner = "potassco";
      repo = "clingo";
      tag = "v${finalAttrs.version}";
      sha256 = "sha256-VhfWGAcrq4aN5Tgz84v7vLOWexsA89vRaang58SXVyI=";
    };

    nativeBuildInputs = [ cmake ];

    cmakeFlags = [
      "-DCLINGO_BUILD_WITH_PYTHON=ON"
      "-DPYTHON_EXECUTABLE=${lib.getExe python.pythonOnBuildForHost}"
    ];

    propagatedBuildInputs = [
      python
      cffi
    ];

    pythonImportsCheck = [
      "clingo"
    ];

    meta = {
      description = "Python interface to clingo, an ASP system to ground and solve logic programs";
      license = lib.licenses.mit;
      maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
      platforms = lib.platforms.unix;
      homepage = "https://potassco.org/";
      downloadPage = "https://github.com/potassco/clingo/releases/";
    };
  })
)
