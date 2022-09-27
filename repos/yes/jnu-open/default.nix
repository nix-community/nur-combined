{ lib
, stdenvNoCC
, fetchzip
, python3
, rp ? ""
}:

let
  version = "unstable-2022-09-27";
  commit = "8c876594cb5d288c8de507f670e2522dfc63b03d";
in

stdenvNoCC.mkDerivation rec {
  inherit version;
  pname = "jnu-open";
  
  src = fetchzip {
    url = "${rp}https://github.com/SamLukeYes/jnu-open/archive/${commit}.zip";
    hash = "sha256-KKmlJT48VG0fyqn1LJwHXMt7CFWRSGX0EwD1EzsUXjA=";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/bin
    cp jnu-open.py $out/bin/jnu-open
  '';

  meta = with lib; {
    description = "Bypass the WeChat authentication of some jnu.edu.cn sites";
    homepage = "https://github.com/SamLukeYes/jnu-open";
    license = licenses.mit;
  };
}