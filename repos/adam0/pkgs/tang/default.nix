{
  # keep-sorted start
  buildGo125Module,
  fetchgit,
  lib,
  # keep-sorted end
}:
buildGo125Module rec {
  pname = "tang";
  version = "0.0.3";
  commit = "b70dd08c7e50d309a9e0364726bb10e0ef5a8698";

  src = fetchgit {
    url = "https://tangled.org/onev.cat/tang";
    tag = "v${version}";
    hash = "sha256-67sM40z9urUB5KxkaiJjRcscCcqdG+WLqjpIxDp1LXg=";
  };

  vendorHash = "sha256-OBKIlZUGbvH6Om5/IicVmpXddROpdsKpJe87YvKZnzo=";

  ldflags = [
    "-X main.version=${version}"
    "-X main.commit=${commit}"
  ];

  subPackages = ["cmd/tang"];

  meta = with lib; {
    # keep-sorted start
    description = "Command-line client for Tangled";
    homepage = "https://tangled.org/onev.cat/tang";
    license = licenses.mit;
    mainProgram = "tang";
    platforms = platforms.unix;
    # keep-sorted end
  };
}
