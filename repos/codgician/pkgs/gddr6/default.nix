{
  lib,
  stdenv,
  cmake,
  pciutils,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "gddr6";
  version = "0-unstable-2024-08-23";

  src = fetchFromGitHub {
    owner = "olealgoritme";
    repo = pname;
    rev = "3825f4246c97ba903e5bacb2ad880574ff4ee65f";
    hash = "sha256-kaesDu1tqkC5C9gTiSN1RYOI+7cMYSY4YobQr92Xv9U=";
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
}
