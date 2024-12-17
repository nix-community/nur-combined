{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "wofi-power-menu";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "szaffarano";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-V1aN8jkWmZz+ynVzZlDE/WYSBnt8XpPEb6NImd6OA4g=";
  };

  cargoHash = "sha256-KWpPyuI963v4D5uLUBNoLWU29lM1PD46uSR1LAUI+Es=";

  meta = with lib; {
    description = "Highly configurable power menu using the wofi launcher power-menu";
    homepage = "https://github.com/szaffarano/wofi-power-menu";
    license = with licenses; [mit];
    platforms = platforms.linux;
    maintainers = with maintainers; [pborzenkov];
  };
}
