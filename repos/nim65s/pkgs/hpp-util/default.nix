{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  jrl-cmakemodules,
  tinyxml-2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-util";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-util";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wCZtkUnPct44g0rNOk+2Ey60n+AHzr3ZWUmIau8reas=";
  };

  prePatch = ''
    substituteInPlace tests/run_debug.sh.in \
      --replace-fail /bin/bash ${stdenv.shell}
  '';

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    boost
    tinyxml-2
    jrl-cmakemodules
  ];

  doCheck = true;

  meta = {
    description = "Debugging tools for the HPP project";
    homepage = "https://github.com/humanoid-path-planner/hpp-util";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
