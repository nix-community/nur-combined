{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  jrl-cmakemodules,
  example-robot-data,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-environments";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-environments";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gvYIICVS4DHzVeSrZZs3tszaIV7EBCOWLs9UJ7H9ZY4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    python3
    cmake
  ];
  propagatedBuildInputs = [
    jrl-cmakemodules
    example-robot-data
  ];

  doCheck = true;

  meta = {
    description = "Environments and robot descriptions for HPP";
    homepage = "https://github.com/humanoid-path-planner/hpp-environments";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
