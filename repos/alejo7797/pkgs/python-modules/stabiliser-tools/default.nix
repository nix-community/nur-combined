{
  lib,
  fetchFromGitHub,
  stdenv,
  buildPythonPackage,
  cmake,
  setuptools,
  catch2_3,
  pybind11,
}:

let
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "ndesilva";
    repo = "stabiliser-tools";
    # Commit used to build https://pypi.org/project/stabiliser-tools/${version}
    rev = "8a1c2e88233928a9b1fed0296aee3c8c20609b0b";
    hash = "sha256-hwkTgNRS72NevbYYVUzDFMNHqaqtp+cnX+9Na6nCKoU=";
  };

  extension = stdenv.mkDerivation {
    pname = "libfast_stabiliser.so";
    inherit src version;

    nativeBuildInputs = [
      cmake
    ];

    buildInputs = [
      catch2_3
      pybind11
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out && cp cpp/src/*.so $out
      runHook postInstall
    '';
  };
in

buildPythonPackage {
  pname = "stabiliser-tools";
  inherit version src;

  sourceRoot = "${src.name}/stabiliser-tools";
  pyproject = true;

  build-system = [
    setuptools
  ];

  preBuild = ''
    cp ${extension}/*.so src/stab_tools
  '';

  pythonImportsCheck = [
    "stab_tools"
  ];

  meta = {
    description = "Fast algorithms for verifying and converting specifications of stabiliser states and Clifford gates";
    license = lib.licenses.gpl3Plus;
    homepage = "https://github.com/ndesilva/stabiliser-tools";
  };
}
