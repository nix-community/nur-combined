{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-core,
  hpp-universal-robot,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-manipulation";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-manipulation";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cohYTpmrCsihslwp2D3zf8r4/IvEuhdOQSciv7fOYU4=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hpp-core
    hpp-universal-robot
  ];

  doCheck = true;

  meta = {
    description = "";
    homepage = "https://github.com/humanoid-path-planner/hpp-manipulation";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
