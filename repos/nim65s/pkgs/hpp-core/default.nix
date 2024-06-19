{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-constraints,
  hpp-pinocchio,
  hpp-statistics,
  proxsuite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-core";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-core";
    #rev = "v${finalAttrs.version}";
    # after hpp-core#341 for pin3+hpp
    rev = "65fae267ff44e7169ff5f9fcde1d3d2d202c3894";
    hash = "sha256-4rNLfNhjHN8PgmVX6YZTgy8ahmz6ovYuyhZdWEJoBg4=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hpp-constraints
    hpp-pinocchio
    hpp-statistics
    proxsuite
  ];

  doCheck = true;

  meta = {
    description = "The core algorithms of the Humanoid Path Planner framework";
    homepage = "https://github.com/humanoid-path-planner/hpp-core";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
