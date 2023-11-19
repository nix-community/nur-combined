{ stdenv, lib, fetchurl }:
let
  version = "1.24.0";
  jar = fetchurl {
    url =
      "https://github.com/DiscordSRV/DiscordSRV/releases/download/v${version}/DiscordSRV-Build-${version}.jar";
    sha256 = "0dadiryjx8v761zh1im7piar3dh4aqs0ccsfyglaqn37m078wwrz";
  };
in stdenv.mkDerivation rec {
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
    description = "Discord bridging plugin for block game.";
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ zeratax ];
  };
}
