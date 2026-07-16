{
  lib,
  stdenv,
  cmake,
  pciutils,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (_: {
  pname = "gddr6";
  version = "0-unstable-2026-07-15";

  src = fetchFromGitHub {
    owner = "olealgoritme";
    repo = "gddr6";
    rev = "0ace205dfd19a432580dd87376cc708800442460";
    hash = "sha256-IV69yWFk0bBrsr/x+50MvA640dqmRQjk2R/dwWaDHjo=";
  };

  buildInputs = [ cmake ];
  nativeBuildInputs = [ pciutils ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=master"
    ];
  };

  meta = {
    description = "Linux​ based GDDR6/GDDR6X VRAM temperature reader for NVIDIA RTX 3000/4000 series GPUs.";
    homepage = "https://github.com/olealgoritme/gddr6";
    maintainers = with lib.maintainers; [ codgician ];
  };
})
