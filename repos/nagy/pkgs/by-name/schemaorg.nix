{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "schemaorg";
  version = "30.0";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yWaej3mOxI0eBYnNFBs/4vYldxcooq91fDDdS5wfVHk=";
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
