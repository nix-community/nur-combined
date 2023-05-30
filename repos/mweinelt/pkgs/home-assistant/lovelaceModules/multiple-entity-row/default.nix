{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "multiple-entity-row";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "benct";
    repo = "lovelace-multiple-entity-row";
    rev = "v${version}";
    sha256 = "sha256-3CkBzxB3bX4jwk71PaRMX1MkAb6UVOBqZCYpTN7VORY=";
  };

  installPhase = ''
    mkdir $out
    cp multiple-entity-row.js $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/benct/lovelace-multiple-entity-row";
    description = "Show multiple entity states and attributes on entity rows in Home Assistant's Lovelace UI";
    license = licenses.mit;
  };
}
