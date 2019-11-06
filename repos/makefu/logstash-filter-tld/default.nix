{ pkgs, stdenv, lib, fetchFromGitHub }:


stdenv.mkDerivation rec {
  name = "logstash-filter-tld-${version}";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "logstash-plugins";
    repo = "logstash-filter-tld";
    rev = "v${version}";
    sha256 = "0ix5w9l6hrbjaymka7fzymjvpkiias3hs0l77zdpcwdaa6cz53nf";
  };

  dontBuild    = true;
  dontPatchELF = true;
  dontStrip    = true;
  dontPatchShebangs = true;
  installPhase = ''
    mkdir -p $out/logstash
    cp -r lib/* $out
  '';

  meta = with lib; {
    description = "logstash filter plugin";
    homepage    = https://github.com/logstash-plugins/logstash-filter-tld;
    license     = licenses.asl20;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ makefu ];
  };
}
