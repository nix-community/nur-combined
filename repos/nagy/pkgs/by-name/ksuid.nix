{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "ksuid";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "segmentio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-50molk1vt8/n4Y+ruayW/EAn9NeeQ8ApmLJQVePhieE=";
  };

  vendorHash = null;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "K-Sortable Globally Unique IDs";
    license = licenses.mit;
  };
}
