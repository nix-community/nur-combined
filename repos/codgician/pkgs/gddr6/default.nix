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
  version = "0-unstable-2026-07-19";

  src = fetchFromGitHub {
    owner = "olealgoritme";
    repo = "gddr6";
    rev = "7ef74c599778e5ad20fbb04ab75aa355018d4a35";
    hash = "sha256-E2WHgNYMbVmd0RRkOvteR+Eu/o3CDfYipZpxt7Cg+74=";
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
