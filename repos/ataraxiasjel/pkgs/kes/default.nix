{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "kes";
  version = "2025-03-12T09-35-18Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "kes";
    rev = version;
    hash = "sha256-S2RdYe07MbQ2xTJLOHYG7rHWxzEeZn6JwjyuWDbkTkY=";
  };

  vendorHash = "sha256-+n1yiAD7STcf73fpkQEPczHK0Pv2ESkdBE8KA4pNsBk=";

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
