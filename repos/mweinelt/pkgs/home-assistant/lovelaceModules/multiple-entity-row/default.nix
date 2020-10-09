{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "multiple-entity-row";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "benct";
    repo = "lovelace-multiple-entity-row";
    rev = "v${version}";
    sha256 = "1m4nc9wjd4af32x4wwyi5x1728vc92as2dzy2q5w6qna6z7f7fxj";
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
