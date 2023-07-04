{ lib, fetchFromGitHub, makeWrapper, python3, stdenv, openssl }:

let 
  pyenv = python3.withPackages (pp: with pp; [
    netifaces
  ]);

in

python3.pkgs.buildPythonApplication rec {
  pname = "Responder";
  version = "3.1.3.0";
  format = "other";
  src = fetchFromGitHub {
    owner = "lgandx";
    repo = "Responder";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-ZnWUkV+9fn08Ze4468wSUtldABrmn+88N2Axc+Mip2A=";
    };

  nativeBuildInputs = [
    makeWrapper
    openssl
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share $out/share/Responder
    cp -R . $out/share/Responder
    openssl genrsa -out $out/share/Responder/certs/responder.key 2048
    openssl req -new -x509 -days 3650 -key $out/share/Responder/certs/responder.key -out $out/share/Responder/certs/responder.crt -subj "/"
    makeWrapper ${pyenv.interpreter}  $out/bin/Responder --add-flags "$out/share/Responder/Responder.py" --run "mkdir -p /tmp/Responder"
    sed -i 's,Responder-Session.log,/tmp/Responder/Responder-Session.log,g' $out/share/Responder/Responder.conf
    sed -i 's,Poisoners-Session.log,/tmp/Responder/Poisoners-Session.log,g' $out/share/Responder/Responder.conf
    sed -i 's,Analyzer-Session.log,/tmp/Responder/Analyzer-Session.log,g' $out/share/Responder/Responder.conf
    sed -i 's,Config-Responder.log,/tmp/Responder/Config-Responder.log,g' $out/share/Responder/Responder.conf
    sed -i 's,Responder.db,/tmp/Responder/Responder.db,g' $out/share/Responder/Responder.conf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Responder is a LLMNR, NBT-NS and MDNS poisoner, with built-in HTTP/SMB/MSSQL/FTP/LDAP rogue authentication server supporting NTLMv1/NTLMv2/LMv2, Extended Security NTLMSSP and Basic HTTP authentication";
    homepage = "https://github.com/lgandx/Responder";
    mainProgram = "Responder";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
  };
}
