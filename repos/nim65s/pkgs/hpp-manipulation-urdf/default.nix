{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hpp-manipulation,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpp-manipulation-urdf";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "humanoid-path-planner";
    repo = "hpp-manipulation-urdf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HnQNOLMvnZft2JuUFTz8wJs7ihVJZYD/KiUCtBGwHmg=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ hpp-manipulation ];
  doCheck = true;

  meta = {
    description = "";
    homepage = "https://github.com/humanoid-path-planner/hpp-manipulation-urdf";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
