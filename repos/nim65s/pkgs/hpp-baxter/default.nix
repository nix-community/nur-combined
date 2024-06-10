{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  example-robot-data,
  jrl-cmakemodules,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-baxter";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-baxter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hK+6Ms43Dg6dUAYqC2cSB4U6Sfpws1F49UlrH6x+a5k=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ jrl-cmakemodules ];

  # fixme: pythonSupport
  buildInputs = [
    python3Packages.python
    python3Packages.eigenpy
    python3Packages.boost
    python3Packages.pinocchio
    python3Packages.example-robot-data
  ];

  doCheck = true;

  meta = {
    description = "Wrappers for Baxter robot in HPP";
    homepage = "https://github.com/humanoid-path-planner/hpp-baxter";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
