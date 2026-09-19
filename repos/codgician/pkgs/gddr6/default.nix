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
  version = "0-unstable-2026-09-19";

  src = fetchFromGitHub {
    owner = "olealgoritme";
    repo = "gddr6";
    rev = "586c77ac61ae06a2992bc8e86b9def95c8151e96";
    hash = "sha256-xUY9TdsZJ3zyFv1F/4GBcY2i7urozghaSnJM+UdGkrY=";
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
