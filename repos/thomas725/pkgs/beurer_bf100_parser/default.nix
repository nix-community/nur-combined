{ lib
, rustPlatform
, fetchFromGitLab
}:

let
  rev = "d5b4eeba628730008b9e6f9f111eb26a4d767020";
in
rustPlatform.buildRustPackage rec {
  pname = "beurer_bf100_parser";
  version = "git-${builtins.substring 0 7 rev}";

  src = fetchFromGitLab {
    owner = "thomas351";
    repo  = "beurer_bf100_parser";
    inherit rev;
    hash = "sha256-WPwbEyNN1GwjUNZKb1njlQkZVNxzv+pu6UOwV0lUYgw=";
    domain = "gitlab.com";
  };
  cargoHash = "sha256-p9gtbBdWNCJ1EhFe62uK4WbDutGnHHN3OjVLIsq52rE=";

  meta = with lib; {
    description = "Parser for Beurer BF100 scale data";
    homepage    = "https://gitlab.com/thomas351/beurer_bf100_parser";
    license     = licenses.agpl3Only;
    platforms   = platforms.unix;
  };
}