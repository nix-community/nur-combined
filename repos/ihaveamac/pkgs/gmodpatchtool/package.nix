{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "gmodpatchtool";
  version = "20260722";

  src = fetchFromGitHub {
    owner = "solsticegamestudios";
    repo = "GModPatchTool";
    tag = version;
    hash = "sha256-eIdgJSkZJ51PwRnf2cD+us9z/GRFSEk1ozT8GlalsHA=";
    fetchLFS = true;
  };

  cargoHash = "sha256-2+FS5gFDeXe1yPMtCFJnaTkp+ImzbJG6SrL5y3U3ZFI=";

  meta = with lib; {
    description = "Patches for Garry's Mod. Updates/Improves CEF and Fixes common launch/performance issues (esp. on Linux/Proton/macOS)";
    homepage = "https://github.com/ticky/lnshot";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    mainProgram = "gmodpatchtool";
  };
}
