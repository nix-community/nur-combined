{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
}:
buildFishPlugin rec {
  pname = "fifc";
  version = "unstable-2026-03-14";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = pname;
    rev = "84bb616ef6ff7725094653be7cb9def9732a8b90";
    hash = "sha256-MV4r0xRQ9v71/F/HJsVYmXpP6zGtq9lUCkKt4ciXYRM=";
  };

  meta = {
    description = "Fzf-powered fish completions with customizable completion rules";
    homepage = "https://github.com/adam01110/fifc";
    license = lib.licenses.mit;
  };
}
