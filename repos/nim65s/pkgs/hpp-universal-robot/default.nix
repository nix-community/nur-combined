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
  pname = "hpp-universal-robot";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-universal-robot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fmyOCDobWjFdPsSEK7yhjrDdLeucZ0S3j4V2B5a7GyI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
  ];
  propagatedBuildInputs = [
    jrl-cmakemodules
    example-robot-data
  ];

  doCheck = true;

  meta = {
    description = "Data specific to robots ur5 and ur10 for hpp-corbaserver";
    homepage = "https://github.com/humanoid-path-planner/hpp-universal-robot";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
