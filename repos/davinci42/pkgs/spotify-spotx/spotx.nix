{ fetchurl }:
let
  rev = "5cf0c31eb736af4c54624d517430790c5616bb82";
in
rec {
  pname = "spotx";
  version = "0-unstable-2026-10-03";
  name = "${pname}-${version}";
  src =
    fetchurl {
      url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/${rev}/spotx.sh";
      hash = "sha256-hZ7XT5oujAwHHf6jPNy3phXqjAQ0TFGskTYe5mdWS0A=";
    }
    // {
      inherit rev;
    };
}
