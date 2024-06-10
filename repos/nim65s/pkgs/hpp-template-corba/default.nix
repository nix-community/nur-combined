{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-util,
  omniorb,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-template-corba";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-template-corba";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CwcQUQ3y2cEP3U6qY9evQQMrkejQAEsWTBrwcQfK4O0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  propagatedBuildInputs = [
    hpp-util
    omniorb
  ];

  doCheck = true;

  meta = {
    description = "This package is intended to ease construction of CORBA servers by templating actions that are common to all servers";
    homepage = "https://github.com/humanoid-path-planner/hpp-template-corba";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
