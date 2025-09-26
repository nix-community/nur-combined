{
  lib,
  buildGoModule,
  fetchFromGitHub,
# nix-update-script,
}:

buildGoModule rec {
  pname = "kes";
  version = "2025-01-30T09-41-53Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-mH89gPvYaO58RluAFuLqgFJELlQSfQrRivLyudMxmnw=";
  };

  vendorHash = "sha256-DTfm0cw3PR01C04FA8tJaBtGYKed42k0K6il2wDmMyE=";

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
