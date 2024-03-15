{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
}:

buildGoModule rec {
  pname = "kes";
  version = "2024-03-13T17-52-13Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-ilI2cuoFiuCaz/euTaMvE3I+A3se5B7zBKGUU4B8aPE=";
  };

  vendorHash = "sha256-Li9xOSa1N1frYesZSyCB2qZUJibNcbWHc6vnuHq0fWM=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Key Managament Server for Object Storage and more";
    homepage = "https://github.com/minio/kes";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  };
}
