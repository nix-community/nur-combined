{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "gmodpatchtool";
  version = "20260623";

  src = fetchFromGitHub {
    owner = "solsticegamestudios";
    repo = "GModPatchTool";
    # due to LFS, i need to use this thing
    rev = "refs/tags/${version}";
    hash = "sha256-3dlLgvhagLugT5s1jdtDbu46gVlTSbUySONvzMqiCEM=";
    fetchLFS = true;
  };
  
  cargoHash = "sha256-WVvzty6XHhD3IfQbUt/ZvMIW5ZEXfwI/Dzoh4j+V20k=";

  meta = with lib; {
    description = "Patches for Garry's Mod. Updates/Improves CEF and Fixes common launch/performance issues (esp. on Linux/Proton/macOS)";
    homepage = "https://github.com/ticky/lnshot";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    mainProgram = "gmodpatchtool";
  };
}
