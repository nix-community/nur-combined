{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "wofi-power-menu";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "szaffarano";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-KTgXiGTMuHs/h7fAM5KBwoed464sd2/2BM19I5LccVM=";
  };

  cargoSha256 = "sha256-9yctAwu4EUeISEaAoeHZsYTdnewMpIMlzoYalrnEJ9c=";

  meta = with lib; {
    description = "Highly configurable power menu using the wofi launcher power-menu";
    homepage = "https://github.com/szaffarano/wofi-power-menu";
    license = with licenses; [mit];
    platforms = platforms.linux;
    maintainers = with maintainers; [pborzenkov];
  };
}
