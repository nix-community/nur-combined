{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-manipulation-corba,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-tutorial";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp_tutorial";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1uBZTNpc/io5mkZ1K7ZB3fvsAiFoyVCQRGyO0bvh1iQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  propagatedBuildInputs = [ hpp-manipulation-corba ];

  doCheck = true;

  meta = {
    description = "Tutorial for humanoid path planner platform";
    homepage = "https://github.com/humanoid-path-planner/hpp_tutorial";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
