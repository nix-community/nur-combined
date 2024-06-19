{
  lib,
  stdenv,
  fetchFromGitHub,
  breakpointHook,
  cmake,
  hpp-core,
  hpp-template-corba,
  omniorbpy,
  pkg-config,
  psmisc,
  python3Packages,
}:
let
  python = python3Packages.python.withPackages (ps: [
    ps.boost
    ps.numpy
    omniorbpy
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-corbaserver";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-corbaserver";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OTcrqqVhH4S8Nw1LCAJLPvO65s+Y60yHVZJ2m/e+gpE=";
  };

  prePatch = ''
    substituteInPlace tests/hppcorbaserver.sh \
      --replace-fail /bin/bash ${stdenv.shell}

  '';

  nativeBuildInputs = [
    breakpointHook
    cmake
    pkg-config
  ];
  buildInputs = [ python ];
  propagatedBuildInputs = [
    hpp-core
    hpp-template-corba
    omniorbpy
  ];
  checkInputs = [ psmisc ];

  enableParallelBuilding = false;

  doCheck = true;

  meta = {
    description = "";
    homepage = "https://github.com/humanoid-path-planner/hpp-corbaserver";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
