{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
}:

buildGoModule rec {
  pname = "kes";
  version = "2024-02-29T08-12-28Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-ryokJ8jw5yts6xG/kvzsBWYKXf5zGmETOqkVOhRABzI=";
  };

  vendorHash = "sha256-pEtBhsihraxl3IBwE1EGECEBwBSF36AqndjNrRaLnYU=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/minio/kes";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
