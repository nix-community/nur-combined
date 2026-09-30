{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "schemaorg";
  version = "30.1";

  src = fetchFromGitHub {
    owner = "schemaorg";
    repo = "schemaorg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2qHRMXgR7xfXDlAYcBhquUjZ8hjqm0Nw+hthrl4uj/Q=";
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
    maintainers = with lib.maintainers; [ nagy ];
  };
})
