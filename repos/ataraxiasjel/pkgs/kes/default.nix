{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "kes";
  version = "2024-10-31T07-42-41Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-ZmNYK87yMXXWsTFplxJ7xwOAGZgH1GXzE2Tp5Dy8xAE=";
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
