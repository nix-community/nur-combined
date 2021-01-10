{ stdenvNoCC, lib, fetchFromGitHub }:
stdenvNoCC.mkDerivation rec {
  pname = "schemaorg";
  version = "11.0";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    rev = "v${version}-release";
    sha256 = "03viqwkvpzkh2hln5b85xic7ssjjydaklnql21kijr7brykkmzf9";
  };

  installPhase = ''
    mkdir -p "$out/share/schema.org/"
    cp -r "data/releases/${version}/." "$out/share/schema.org/"
  '';

  meta = with lib ; {
    description = "schema.org";
    homepage = "schema.org";
    license = licenses.asl20;
    changelog = "https://schema.org/docs/releases.html";
  };
}
