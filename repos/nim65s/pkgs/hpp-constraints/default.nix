{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  hpp-pinocchio,
  hpp-statistics,
  qpoases,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-constraints";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-constraints";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JU1ocV3NLB6thNVGh5ru+Gehq/VcPwvjfMiZGBsEnhU=";
  };

  patches = [
    (fetchpatch {
      name = "fix-jrlcmakemodules-path.patch";
      url = "https://github.com/humanoid-path-planner/hpp-constraints/pull/195.patch";
      hash = "sha256-PvEv0uj06r6ANFmAhH+QIKB540frgGDEOXuraGT1g0k=";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    hpp-pinocchio
    hpp-statistics
    qpoases
  ];

  doCheck = true;

  meta = {
    description = "Definition of basic geometric constraints for motion planning";
    homepage = "https://github.com/humanoid-path-planner/hpp-constraints";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
