{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "schemaorg";
  version = "14.0";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    rev = "V${version}-release";
    sha256 = "sha256-qPctk66RZycaZEc17X+DIl484I8/V1KlNO2UuUkNTBE=";
  };

  installPhase = ''
    mkdir -p "$out/share/schema.org/"
    cp -r "data/releases/${version}/." "$out/share/schema.org/"
  '';

  meta = with lib; {
    description = "Schema.org - schemas and supporting software";
    homepage = "https://schema.org/";
    license = licenses.asl20;
    changelog = "https://schema.org/docs/releases.html";
  };
}
