{ stdenv, lib, fetchurl }:
let
  version = "1.22.0";
  jar = fetchurl {
    url = "https://github.com/DiscordSRV/DiscordSRV/releases/download/v${version}/DiscordSRV-Build-${version}.jar";
    sha256 = "0lhzil881hngyk0vlw1yp0bw9wh13h9fq7d0dykfhwl9g31n310n";
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "discordsrv";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    cp ${jar} $out/${pname}.jar
  '';

  meta = with lib; {
    homepage = "https://discordsrv.com";
    description =
      "Discord bridging plugin for block game.";
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ zeratax ];
  };
}
