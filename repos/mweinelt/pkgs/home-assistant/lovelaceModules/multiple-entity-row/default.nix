{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "multiple-entity-row";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "benct";
    repo = "lovelace-multiple-entity-row";
    rev = "v${version}";
    sha256 = "0x5k4cdv5spjlg3y6wlw10yhx1fmy7x25y7c5lvb4g9wasnzi3c7";
  };

  installPhase = ''
    mkdir $out
    cp multiple-entity-row.js $out/
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/benct/lovelace-multiple-entity-row";
    description = "Show multiple entity states and attributes on entity rows in Home Assistant's Lovelace UI";
    license = licenses.mit;
  };
}
