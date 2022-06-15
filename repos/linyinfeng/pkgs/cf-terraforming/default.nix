{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "cf-terraforming";
  version = "0.8.0";
  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf-terraforming";
    rev = "v${version}";
    sha256 = "sha256-+GZNxYeVDYgxuhJOE9Y27sfsQvi+9+9IMuKqQygkfhY=";
  };

  vendorSha256 = "sha256-Hid7Q9AAczcW+hY8D+GLyGPDi3DIXk81vtrYwu3QAjM=";

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
