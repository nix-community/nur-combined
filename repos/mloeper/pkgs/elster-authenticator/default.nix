{ lib, stdenv, pkgs, fetchurl, ... }:

stdenv.mkDerivation {
  pname = "elster-authenticator";
  version = "56.1";

  src = fetchurl {
    url = "https://download.elster.de/download/authenticator/ElsterAuthenticator_unix_56_1_0_x64.sh";
    hash = "sha256-zBNdyihmyJxttj3QJYPxcBGn/lqSddW5dzwa18NTMfY=";
  };

  unpackPhase = ":";

  nativeBuildInputs = [ pkgs.makeWrapper pkgs.autoPatchelfHook ];

  buildInputs = with pkgs; [
    jre
    libz
  ];

  installPhase = ''
    install -d $out/bin
    cp $src $out/bin/ElsterAuthenticator_unix_56_1_0_x64.sh
    chmod u+x $out/bin/ElsterAuthenticator_unix_56_1_0_x64.sh
    makeWrapper "$out/bin/ElsterAuthenticator_unix_56_1_0_x64.sh" "$out/bin/ElsterAuthenticator" \
        --inherit-argv0 \
        --set INSTALL4J_JAVA_HOME_OVERRIDE "/tmp/ElsterAuth" \
        --chdir "/tmp/ElsterAuth" \
        --set INSTALL4J_TEMP "/tmps" \
        --set INSTALL4J_KEEP_TEMP "yes" \
        --append-flags -J-Djava.io.tmpdir=/tmp \
        --prefix PATH : ${lib.makeBinPath [
          pkgs.jre
        ]}
  '';


  meta = with lib; {
    homepage = "https://www.elster.de/elsterweb/infoseite/elsterauthenticator";
    description = "Tool to login into Mein ELSTER and authorize operations within the webapp";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ElsterAuthenticator";
    broken = true;
  };
}
