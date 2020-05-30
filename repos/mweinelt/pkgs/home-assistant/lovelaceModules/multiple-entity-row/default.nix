{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "multiple-entity-row";
  version = "v3.1.1";

  src = fetchFromGitHub {
    owner = "benct";
    repo = "lovelace-multiple-entity-row";
    rev = version;
    sha256 = "13wr286r4m9l16cycrldabkr8n7g5g590341qvlk4x00fg7mywmr";
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
