{ stdenv, lib, fetchFromGitHub, makeWrapper, awscli2, jq, detect-secrets }:

stdenv.mkDerivation rec {
  pname = "prowler";
  version = "2.12.1";

  src = fetchFromGitHub {
    owner = "prowler-cloud";
    repo = "prowler";
    rev = version;
    sha256 = "sha256-WvTBqvcWPBDcZzaTeU88KJXKgfeJCkt9bv3JLAzlNNM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/prowler
    cp -r . $out/opt/prowler/

    makeWrapper $out/opt/prowler/prowler $out/bin/prowler \
      --prefix PATH ":" ${lib.makeBinPath [ awscli2 detect-secrets jq ]} 

    runHook postInstall
  '';

  meta = with lib; {
    description = "Security tool to perform AWS security best practices assessments, audits, incident response, continuous monitoring, hardening and forensics readiness";
    homepage = "https://github.com/prowler-cloud/prowler";
    license = licenses.asl20;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = platforms.linux;
  };
}
