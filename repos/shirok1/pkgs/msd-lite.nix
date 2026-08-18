{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation {
  pname = "msd-lite";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "rozhuk-im";
    repo = "msd_lite";
    rev = "fa68e131343fb58c67ad77b2d26f2cb7c49a2c95";
    hash = "sha256-+LMcsU/kfaRD/0OTN4IN84GeFOsuiGCKjtvVP4dyY6g=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Multi stream daemon - lightweight daemon for streaming media";
    homepage = "https://github.com/rozhuk-im/msd_lite";
    license = licenses.bsd2;
    mainProgram = "msd_lite";
  };
}
