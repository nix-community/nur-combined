{ fetchurl }:
let
  rev = "1538ecf26b781e1bc6486fe4360ef51bd4d402d7";
in
rec {
  pname = "spotx";
  version = "0-unstable-2026-09-28";
  name = "${pname}-${version}";
  src =
    fetchurl {
      url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/${rev}/spotx.sh";
      hash = "sha256-pCUr/crowEeYlEkxdYim4g9hCcbW0N0FfOl8OpEdjo8=";
    }
    // {
      inherit rev;
    };
}
