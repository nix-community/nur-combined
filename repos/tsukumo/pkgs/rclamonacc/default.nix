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
    rev = "dacd7d52855666de70f5cd6eb281ebe11e939546";
    hash = "sha256-M1gbtRIuMlY+gRrBXFBCJseu+SMipM5YyBugR+17LfM=";
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
