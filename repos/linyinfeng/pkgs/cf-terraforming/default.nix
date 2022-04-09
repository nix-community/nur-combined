{ sources, buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  inherit (sources.cf-terraforming) pname version src;

  vendorSha256 = "sha256-vD8EGXRzEl47ZBTlGYpVlW8zJF5NneGIcY93IpFDw58=";

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
