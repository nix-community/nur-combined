{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
}:
buildFishPlugin rec {
  pname = "fifc";
  version = "unstable-2026-03-13";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = pname;
    rev = "9b7aa249fa096c5bb8e6d8fd8e54212c42f5f168";
    hash = "sha256-F+qoYFkXb5mYIsDt4/Psau/iTvVAMRaSInopsfeP5UA=";
  };

  meta = {
    description = "Fzf-powered fish completions with customizable completion rules";
    homepage = "https://github.com/adam01110/fifc";
    license = lib.licenses.mit;
  };
}
