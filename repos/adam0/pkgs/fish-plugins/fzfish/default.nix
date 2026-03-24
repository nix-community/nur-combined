{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
}:
buildFishPlugin {
  pname = "fzfish";
  version = "unstable-2026-03-23";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = "FzFish";
    rev = "ccc9a53c74aead741720d0e27eaa092794f740ad";
    hash = "sha256-SWn1XYWnGd14aDRTYEishbUC6H0V22SIUfXDdgUUUmI=";
  };

  meta = {
    description = "Fzf-powered fish completions with customizable completion rules";
    homepage = "https://github.com/adam01110/FzFish";
    license = lib.licenses.mit;
  };
}
