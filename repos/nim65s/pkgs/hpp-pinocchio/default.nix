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
    #rev = "v${finalAttrs.version}";
    # after hpp-pinocchio#200 for pin3+hpp
    rev = "b0e839e3bd126a9d6d205311c43f2f4b4f02a79e";
    hash = "sha256-SAHBcGnYnSC1cz22wd3hZtis76AlwTxNz8Zlt+RKVQs=";
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
