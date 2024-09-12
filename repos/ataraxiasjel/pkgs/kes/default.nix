{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
}:

buildGoModule rec {
  pname = "kes";
  version = "2024-09-11T07-22-50Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-X5MEjIITtzgMDI5cHUayJL7kLDP2FRyZ6X8VtY7F0E8=";
  };

  vendorHash = "sha256-3aibbr7pDHyMFjCJLFXhYRMUVS6luA0owVYqdFia6Jw=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/minio/kes";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
