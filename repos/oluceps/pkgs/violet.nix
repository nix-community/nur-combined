{
  lib,
  cmake,
  fetchFromGitHub,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "violet";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "paullouisageneau";
    repo = "violet";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+cAgcGOMlhDdep8VuqP8DeELbMRXydRsD0xTyHqOuYM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Lightweight STUN/TURN server";
    homepage = "https://github.com/paullouisageneau/violet";
    license = lib.licenses.gpl2Only;
    mainProgram = "violet";
    maintainers = with lib.maintainers; [ oluceps ];
    platforms = lib.platforms.all;
  };
})
