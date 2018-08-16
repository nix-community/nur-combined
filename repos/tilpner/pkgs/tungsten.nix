{ stdenvNoCC, fetchFromGitHub, makeWrapper, bash, xmlstarlet }:

stdenvNoCC.mkDerivation {
  name = "tungsten";

  src = fetchFromGitHub {
    owner = "ASzc";
    repo = "tungsten";
    rev = "0928ad73b65692431175be2c7b9f97825b15aac0";
    sha256 = "0wmki0m9zrjiy665s57xma8k9c3cg2agqn4155ai1vz7fkawcg6v";
  };

  buildInputs = [ bash xmlstarlet ];
  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    install -D $src/tungsten.sh $out/bin/tungsten
    substituteInPlace $out/bin/tungsten \
      --replace /bin/bash '/usr/bin/env bash'
    wrapProgram $out/bin/tungsten \
      --prefix PATH : ${xmlstarlet}/bin
  '';

  meta = with stdenvNoCC.lib; {
    description = "A WolframAlpha CLI";
    homepage = https://github.com/ASzc/tungsten;
    license = licenses.gpl3;
  };
}
