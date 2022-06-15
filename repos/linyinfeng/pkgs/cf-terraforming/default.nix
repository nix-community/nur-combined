{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "cf-terraforming";
  version = "0.7.4";
  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf-terraforming";
    rev = "v${version}";
    sha256 = "sha256-H85cuENmDhxIFAsKL0D8w2vOa/EoxN6qmyq5l1z9wAI=";
  };

  vendorSha256 = "sha256-AJ01ykz4/q3q9sdW6L9e4BPn+XGedCrA9Cfh5cnLYaE=";

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
