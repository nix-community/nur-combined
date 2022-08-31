{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "cf-terraforming";
  version = "0.9.0";
  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf-terraforming";
    rev = "v${version}";
    sha256 = "sha256-ohz9fp3UvJxfuQ+66PwGjogOeNnu5fi078h5ns0LW0U=";
  };

  vendorSha256 = "sha256-tlQdgPfrQG6GkBQ8cLfAOygb5jYGIHl+3XRLJks9ky8=";

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
