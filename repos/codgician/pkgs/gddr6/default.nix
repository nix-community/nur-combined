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
  version = "0-unstable-2025-04-21";

  src = fetchFromGitHub {
    owner = "olealgoritme";
    repo = "gddr6";
    rev = "bac2c5e30123a9ed4c0a91072abbdb025bbd9bd3";
    hash = "sha256-cs2vNKSb6BRBtJezn1jqm5JIPZwfHNybRpouAqshEWs=";
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
