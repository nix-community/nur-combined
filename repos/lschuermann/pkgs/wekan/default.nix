{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "wekan-${version}";
  version = "1.53.8";

  src = fetchurl {
    url = "https://releases.wekan.team/${name}.tar.gz";
    sha256 = "0y9nwfll0pncpdaj706amygrkxmfj7i7811mnk629yyqcpfgrvlj";
  };

  installPhase = ''
    mkdir -p $out/
    cp -R . $out/
  '';

  meta = with stdenv.lib; {
    description = "The open-source kanban (built with Meteor)";
    homepage = https://wekan.team;
    maintainers = maintainers.lschuermann;
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
