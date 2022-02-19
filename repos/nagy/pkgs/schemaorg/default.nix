{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "schemaorg";
  version = "13.0";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    rev = "v${version}-release";
    sha256 = "0vg5i2w3mp04dfqrl1wl1flf32qqgg4bzlaxzp6sx6wyznlvn2g3";
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
