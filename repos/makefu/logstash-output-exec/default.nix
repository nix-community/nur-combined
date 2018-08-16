{ pkgs, stdenv, lib, fetchFromGitHub }:


# TODO: requires ftw ruby package
stdenv.mkDerivation rec {
  name = "logstash-input-github-${version}";
  version = "3.1.0";

	src = fetchFromGitHub {
		owner = "logstash-plugins";
    repo = "logstash-output-exec";
    rev = "v${version}";
    sha256 = "0ix5w9l6hrbjaymkh7fzymjvpkiias3hs0l77zdpcwdaa6cz53nf";
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
    description = "logstash output plugin";
    homepage    = https://github.com/logstash-plugins/logstash-output-exec;
    license     = stdenv.lib.licenses.asl20;
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with maintainers; [ makefu ];
  };
}
