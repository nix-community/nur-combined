{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "kes";
  version = "2025-03-12T09-35-18Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    tag = "v${version}";
    hash = "sha256-NpB6+89vQHke60JKy35eqN6xsLGEKLz6zRQRGZex+jQ=";
  };

  vendorHash = "sha256-3aibbr7pDHyMFjCJLFXhYRMUVS6luA0owVYqdFia6Jw=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/minio/kes";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    mainProgram = "kes";
  };
}
