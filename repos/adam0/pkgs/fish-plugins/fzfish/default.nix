{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
}:
buildFishPlugin {
  pname = "fzfish";
  version = "unstable-2026-03-17";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = "FzFish";
    rev = "f9041397bc46217dfc50255746f7710ebe5b14e7";
    hash = "sha256-gygZ0Jc41gvOZQcHfpJIAfRpK8w0A3JRMcojpIo4Zdo=";
  };

  meta = {
    description = "Fzf-powered fish completions with customizable completion rules";
    homepage = "https://github.com/adam01110/FzFish";
    license = lib.licenses.mit;
  };
}
