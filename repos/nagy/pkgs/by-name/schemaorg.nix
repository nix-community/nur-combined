{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "schemaorg";
  version = "29.3";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    rev = "v${finalAttrs.version}-release";
    hash = "sha256-3dPIp4wefz37ML+EB/iy+CDdVYpujQTlKFV+MvAY7YU=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/schema.org/"
    cp -r "data/releases/${finalAttrs.version}/." "$out/share/schema.org/"

    runHook postInstall
  '';

  meta = {
    description = "Schema.org - schemas and supporting software";
    homepage = "https://schema.org/";
    license = lib.licenses.asl20;
    changelog = "https://schema.org/docs/releases.html";
  };
})
