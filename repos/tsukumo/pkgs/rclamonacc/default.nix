{
  lib,
  rustPlatform,
  fetchFromGitHub,
  maintainers,
}:
rustPlatform.buildRustPackage {
  pname = "rclamonacc";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "thukumo";
    repo = "rclamonacc";
    rev = "3ba6463ca706a069b00002171e8cf2c7d1414ef6";
    hash = "sha256-mgBNpTyZF2yh2PPZxuaZwls9c/yG1Kafm2hU/PbGKsw=";
  };
  cargoHash = "sha256-mm4BNA6ArQWilTjs6uoows22RDfEVf67KASDCCtDrD4=";
  meta = with lib; {
    description = "Realtime Scanner like clamonacc";
    license = {
      fullName = "THE STRONGEST PUBLIC LICENSE";
      shortName = "strongest-public-license";
      free = true;
      url = "https://raw.githubusercontent.com/ErikMcClure/bad-licenses/542fb1cda6abbbff72a0919a13ccd2dd27474052/STRONGEST-PUBLIC-LICENSE";
    };
    maintainers = [ maintainers.thukumo ];
    platforms = platforms.linux;
  };
}
