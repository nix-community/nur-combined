{ stdenv, fetchurl, jq }:

let version = "0.4.0"; in
stdenv.mkDerivation {
  name = "ok.sh-${version}";

  src = fetchurl {
    url = "https://github.com/whiteinge/ok.sh/archive/${version}.tar.gz";
    sha256 = "00pbcxkqgrms215x65bq6rqa38579zk59yjhkq03z0xinyqy3xxg";
  };

  buildInputs = [ jq ];
  buildPhase = "true";
  installPhase = ''
    install -D ok.sh $out/bin/ok.sh
  '';

  meta = with stdenv.lib; {
    description = "A Bourne shell GitHub API client library focused on interfacing with shell scripts";
    homepage = https://github.com/whiteinge/ok.sh;
    platforms = with platforms; linux ++ darwin;
    license = licenses.bsd3;
  };
}
