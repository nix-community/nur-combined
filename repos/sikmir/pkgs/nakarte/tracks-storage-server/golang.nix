{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "tracks-storage-server-go";
  version = "0-unstable-2026-07-18";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "sikmir";
    repo = "tracks_storage_server";
    rev = "4e9f277e88016454949e9d24efc40ddb910e9cda";
    hash = "sha256-3YxBhbBkG8eBbUaAqIAlkY4VUgJ4tNemblH2PpiUdgo=";
  };

  vendorHash = "sha256-5RBA1JI0rXgFLx97sYozckt2w5R8qMxzMvzJWZzCDKc=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Tracks storage server";
    homepage = "https://github.com/sikmir/tracks_storage_server";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
