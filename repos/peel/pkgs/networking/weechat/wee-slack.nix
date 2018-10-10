{ stdenv, fetchFromGitHub, weechat, python }:

stdenv.mkDerivation rec {
  version = "2.1.1";
  baseName = "wee-slack";
  name = "${baseName}-${version}";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = baseName;
    repo = baseName;
    sha256 = "05caackz645aw6kljmiihiy7xz9jld8b9blwpmh0cnaihavgj1wc";
  };

  buildInputs = [ weechat (python.withPackages(ps: with ps; [websocket_client])) ];
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share
    cp $src/wee_slack.py $out/share/
  '';

  meta = with stdenv.lib; {
    description = "A native Weechat Slack plugin";
    platforms = platforms.unix;
    license = licenses.mit;
  };
}
