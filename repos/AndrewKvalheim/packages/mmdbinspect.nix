{ buildGoModule
, fetchFromGitHub
, gitUpdater
, lib
}:

buildGoModule rec {
  pname = "mmdbinspect";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "maxmind";
    repo = "mmdbinspect";
    rev = "refs/tags/v${version}";
    hash = "sha256-PYn+NgJDZBP+9nIU0kxg9KYT0EV35omagspcsCpa9DM=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-HNgofsfMsqXttnrNDIPgLHag+2hqQTREomcesWldpMo=";

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Look up records for IPs/networks in .mmdb databases";
    homepage = "https://github.com/maxmind/mmdbinspect";
    license = with lib.licenses; [ asl20 mit ];
  };
}
