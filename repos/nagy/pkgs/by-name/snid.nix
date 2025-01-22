{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "snid";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "AGWA";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-f00lga6nmLJHsfx3sB3oBhfutCmmMddEM5fJptb9EPw=";
  };

  vendorHash = "sha256-6o0Rp7tKt6j1HgRUKwnZ604hOITq64e6zhYl3rw8Wj4=";

  meta = with lib; {
    description = "Zero config SNI proxy server";
    homepage = "https://github.com/AGWA/snid";
    license = licenses.mit;
    mainProgram = "snid";
  };
}
