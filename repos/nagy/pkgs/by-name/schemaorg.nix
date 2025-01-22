{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "schemaorg";
  version = "15.0";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    rev = "v${version}-release";
    sha256 = "sha256-n/+lfGPpgdcq8DS4E2H8PBCdjTq7lsOoOsreDla5PWQ=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/schema.org/"
    cp -r "data/releases/${version}/." "$out/share/schema.org/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Schema.org - schemas and supporting software";
    homepage = "https://schema.org/";
    license = licenses.asl20;
    changelog = "https://schema.org/docs/releases.html";
  };
}
