{ sources, buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  inherit (sources.cf-terraforming) pname version src;

  vendorSha256 = "sha256-1joKUvendiyHu8WF20mk+P0pbRB2/l3EEVpFHPoM3NA=";

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
