{
  lib,
  fetchFromGitea,
  buildGoModule,
}:
buildGoModule {
  pname = "systemd-sops-creds";
  version = "v1.0.0";

  meta = {
    description = "Use your SOPS files as systemd credentials.";
    homepage = "https://codeberg.org/someron/systemd-sops-creds";
    license = lib.licenses.mit;
    mainProgram = "systemd-sops-creds";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "someron";
    repo = "systemd-sops-creds";
    rev = "v1.0.0";
    hash = "sha256-DhsuBSGp4g7KVnTso2iec7iE/tFhAkaxGtfKuEivzbg=";
  };

  vendorHash = "sha256-GInV2f0vXxfIqx4zN1VUOR6C3PaUr4QM3y1gIa5me0k=";
}