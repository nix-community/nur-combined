{ fetchurl }:
let
  rev = "d09abef54106251e51fad0b753513af34a8fa5c0";
in
rec {
  pname = "spotx";
  version = "0-unstable-2026-10-16";
  name = "${pname}-${version}";
  src =
    fetchurl {
      url = "https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/${rev}/spotx.sh";
      hash = "sha256-n89GkB/83Ye/a79WFs363EliB5oLOpqDUy659hNgCs0=";
    }
    // {
      inherit rev;
    };
}
