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
    rev = "7987b2628cf3c9e69602b21415fd21877d6fe3c8";
    hash = "sha256-+rAiKqxwSPGUWRBCVYa1UUnW68NlKIbhQbE3FNItB38=";
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
