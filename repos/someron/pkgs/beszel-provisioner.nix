{
  lib,
  buildGoModule,
  fetchFromGitea
}:
buildGoModule {
  name = "beszel-provisioner";
  version = "2025-09-29";

  meta = {
    description = "Declaratively configure users, systems, alerts and OAuth2 for beszel!";
    homepage = "https://codeberg.org/someron/beszel-provisioner";
    license = lib.licenses.mit;
    mainProgram = "beszel-provisioner";
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "someron";
    repo = "beszel-provisioner";
    rev = "e6aa47ceb4e5499cd7ca9b3868a3dffac192cc0c";
    sha256 = "sha256-pKU0TE6X5ucyODmiJjjP7y1uQFlmEv3e01a1igCLGUg=";
  };

  vendorHash = null;
}
