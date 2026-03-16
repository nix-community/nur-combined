{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "occasion";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "itscrystalline";
    repo = "occasion";
    rev = "v${version}";
    hash = "sha256-A7/tsAiGlXxvcCc+MxKs/QH4YZ2vERJpccKNabpGP/U=";
  };

  cargoHash = "sha256-88AYgNFER+htlkhwQc6b1eIlUn/Q46JvIshqWC/boc4=";

  meta = {
    description = "A small program to print something / run a command on a specific time/timeframe. ";
    homepage = "https://github.com/itscrystalline/occasion";
    license = lib.licenses.unlicense;
    sourceProvenance = [lib.sourceTypes.fromSource];
    mainProgram = "occasion";
    maintainers = [];
  };
}
