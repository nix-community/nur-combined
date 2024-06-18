{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
}:

buildGoModule rec {
  pname = "kes";
  version = "2024-06-17T15-47-05Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-vKEmwwUVIDAXftDe5uyMUNbxHxm17/SWfRx9kL4SbNI=";
  };

  vendorHash = "sha256-FonlBiCXhCeIATS99q39jnsFtH+91yYqZUJ86MInxzI=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/minio/kes";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
