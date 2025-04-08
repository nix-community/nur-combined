{
  lib,
  fetchFromGitea,
  buildGoModule,
}:
buildGoModule rec {
  pname = "safetwitch";
  version = "1.7.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "SafeTwitch";
    repo = "safetwitch-backend";
    rev = "v${version}";
    hash = "sha256-kdmM2hf205uVYAb/pK92pXO1WQMCeSoP5uI511XljM0=";
  };

  vendorHash = "sha256-vXDeXCnxXoHX0kWUaK++lDpYGfls35qorx720xlfbUE=";

  meta = {
    description = "A privacy respecting frontend for twitch.tv";
    homepage = "https://codeberg.org/SafeTwitch/safetwitch-backend";
    license = lib.licenses.agpl3Only;
    mainProgram = "safetwitch";
  };
}
