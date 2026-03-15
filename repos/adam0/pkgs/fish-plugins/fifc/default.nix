{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
}:
buildFishPlugin rec {
  pname = "fifc";
  version = "unstable-2026-03-15";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = pname;
    rev = "322b3a610a7d7a902e3c069c01b341d9c2744876";
    hash = "sha256-uT7z7lBtzJQ8qVen+5HRZzpk6pmcOaReIHAkL4qV5Ag=";
  };

  meta = {
    description = "Fzf-powered fish completions with customizable completion rules";
    homepage = "https://github.com/adam01110/fifc";
    license = lib.licenses.mit;
  };
}
