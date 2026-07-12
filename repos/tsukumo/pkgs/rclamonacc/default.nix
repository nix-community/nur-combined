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
    rev = "a59c44aff515a73506cc6a0aeba2fc443bb6f166";
    hash = "sha256-HBYQCOPrMlI0W234fYW/lNrhPbTRqbD8o4WtA+5f2qI=";
  };
  cargoHash = "sha256-XjLMb7EN/Pso/ViEuDkbMAsoQPAVJg+F6OoS4YnWIho=";
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
