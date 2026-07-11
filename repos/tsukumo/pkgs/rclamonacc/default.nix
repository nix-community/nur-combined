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
    rev = "badfbab120abfd01f0fe686161dc6806ec30c73c";
    hash = "sha256-i43AkTk0XDbg3qERA/k5RTBvM3TvLNUGSzECzqSQdEk=";
  };
  cargoHash = "sha256-Ci2z2v4GKVAhdsNYNpdQJTNHPzwDqiR3Jb6/9/p6ikg=";
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
