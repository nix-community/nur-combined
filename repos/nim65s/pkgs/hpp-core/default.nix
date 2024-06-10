{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-constraints,
  hpp-pinocchio,
  hpp-statistics,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-core";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-core";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2gaI2mqnP+OgcDG3zPgH65xOy96gzsAFmZLcIk7jMoc=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hpp-constraints
    hpp-pinocchio
    hpp-statistics
  ];

  doCheck = true;

  meta = {
    description = "The core algorithms of the Humanoid Path Planner framework";
    homepage = "https://github.com/humanoid-path-planner/hpp-core";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
