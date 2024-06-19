{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-corbaserver,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-romeo";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp_romeo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OCSXiKWcwPnRL545VyLaVOEBoG3pCzQBp+OIDy4Gu1I=";
  };

  strictDeps = true;
  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  propagatedBuildInputs = [ hpp-corbaserver ];

  meta = {
    description = "Python and ros launch files for Romeo robot in hpp";
    homepage = "https://github.com/humanoid-path-planner/hpp_romeo";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
