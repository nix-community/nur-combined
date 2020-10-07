{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "multiple-entity-row";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "benct";
    repo = "lovelace-multiple-entity-row";
    rev = "v${version}";
    sha256 = "1rd6bq3qzb7w7ahdgwf6xkd4kh9zdvz3172v30ghc0s7kv6irfrq";
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
