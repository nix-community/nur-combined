{ fetchurl }:
let
  rev = "d7c7b60f318f03884c02b4254e7bfd1701f17b70";
in
rec {
  pname = "spotx";
  version = "0-unstable-2026-10-08";
  name = "${pname}-${version}";
  src =
    fetchurl {
      url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/${rev}/spotx.sh";
      hash = "sha256-BWBeGyNNnXlWXEpJyd3p+0ESF3dLWsMqui3zHnzbsHE=";
    }
    // {
      inherit rev;
    };
}
