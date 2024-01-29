{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
}:

buildGoModule rec {
  pname = "kes";
  version = "2024-01-11T13-09-29Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-nxYfLFmv5tgN8nZ9tVvEpsMrrBx9pLZigezl6CWBG1o=";
  };

  vendorHash = "sha256-VC1bNS+NUyiqvdb0OK1RoIrEjPqMpdhw2lPL3GKaN8A=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/minio/kes";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
