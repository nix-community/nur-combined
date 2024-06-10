{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-util,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-statistics";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-statistics";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zu4n0izRyufRYfwhPk+HbMQsDh+0Z1A8fVdLXkZEjDY=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ hpp-util ];

  doCheck = true;

  meta = {
    description = "Classes for doing statistics";
    homepage = "https://github.com/humanoid-path-planner/hpp-statistics";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
