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
  version = "0-unstable-2026-07-31";

  src = fetchFromGitHub {
    owner = "olealgoritme";
    repo = "gddr6";
    rev = "b5e11b1d75c11ac275b4abdcae60e1bdeb9f0de4";
    hash = "sha256-lHkx3idy5eNP3nUvNmEUzQtDWkTf8LnXhs6gzy3MBvk=";
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
