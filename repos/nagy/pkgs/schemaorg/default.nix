{ stdenvNoCC, lib, fetchFromGitHub }:
stdenvNoCC.mkDerivation rec {
  pname = "schemaorg";
  version = "12.0";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    rev = "v${version}-release";
    sha256 = "1pzhkiq4nxfshmvajd0x3w26xnyikjf388rfx48xs2f4nfagfa5q";
  };

  installPhase = ''
    mkdir -p "$out/share/schema.org/"
    cp -r "data/releases/${version}/." "$out/share/schema.org/"
  '';

  meta = with lib; {
    description = "schema.org";
    homepage = "https://schema.org/";
    license = licenses.asl20;
    changelog = "https://schema.org/docs/releases.html";
  };
}
