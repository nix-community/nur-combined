{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-environments,
  hpp-util,
  pinocchio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-pinocchio";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-pinocchio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-m7GfVNYahe+1UAvnnXZD/cU41NUZ1HmBGPosAna794k=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hpp-environments
    hpp-util
    pinocchio
  ];

  doCheck = true;

  meta = {
    description = "Wrapping of Pinocchio library into HPP";
    homepage = "https://github.com/humanoid-path-planner/hpp-pinocchio";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
