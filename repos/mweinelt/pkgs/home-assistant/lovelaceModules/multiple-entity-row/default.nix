{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "multiple-entity-row";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "benct";
    repo = "lovelace-multiple-entity-row";
    rev = "v${version}";
    sha256 = "114518wcq2b1phrbzq98q8vf6gc1rb4sr9yb3yjxxqjcbxf4gibq";
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
