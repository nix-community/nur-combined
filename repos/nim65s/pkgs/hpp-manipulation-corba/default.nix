{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-corbaserver,
  hpp-manipulation-urdf,
  omniorbpy,
  pkg-config,
  python3Packages,
}:
let
  python = python3Packages.python.withPackages (_ps: [

    omniorbpy
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-manipulation-corba";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-manipulation-corba";
    rev = "v${finalAttrs.version}";
    hash = "sha256-X59Qr97gMNV0h6U7D/RG37rvd2q7jsL1Rpf7pNfDOIs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [ python ];
  propagatedBuildInputs = [
    hpp-corbaserver
    hpp-manipulation-urdf
    omniorbpy
  ];

  enableParallelBuilding = false;

  doCheck = true;

  meta = {
    description = "Corba server for manipulation planning";
    homepage = "https://github.com/humanoid-path-planner/hpp-manipulation-corba";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
