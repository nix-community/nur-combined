{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "cf-terraforming";
  version = "0.8.2";
  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf-terraforming";
    rev = "v${version}";
    sha256 = "sha256-Lmcb5W5RnASF2Gdr2oFuM/nH48vhPabyD9OTNJnvOoY=";
  };

  vendorSha256 = "sha256-INwbKcdynkcO6bDkJ3MR7tS+6OFm7yQDafv5Iv9p/50=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/cloudflare/cf-terraforming/internal/app/cf-terraforming/cmd.versionString=${version}"
  ];

  doCheck = false;

  meta = with lib; {
    description = "A command line utility to facilitate terraforming your existing Cloudflare resources";
    homepage = "https://github.com/cloudflare/cf-terraforming";
    license = licenses.mpl20;
  };
}
