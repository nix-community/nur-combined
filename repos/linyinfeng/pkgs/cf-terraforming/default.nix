{
  buildGoModule,
  fetchFromGitHub,
  go_latest,
  lib,
  nix-update-script,
}:

# nixpkgs' default go lags behind upstream's go.mod, so build with the newest
# one available.
(buildGoModule.override { go = go_latest; }) rec {
  pname = "cf-terraforming";
  version = "0.30.0";
  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf-terraforming";
    rev = "v${version}";
    sha256 = "sha256-ju/qOwwtBciEfBYZ9W82p2KUF0hoA1UKbt12QWhZ5PQ=";
  };

  vendorHash = "sha256-7/VRs7BEFLCx7sqIbOFA7b7tQwlpgzeWYUdgankHNCo=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/cloudflare/cf-terraforming/internal/app/cf-terraforming/cmd.versionString=${version}"
  ];

  doCheck = false;

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "A command line utility to facilitate terraforming your existing Cloudflare resources";
    homepage = "https://github.com/cloudflare/cf-terraforming";
    license = licenses.mpl20;
    broken = !(versionAtLeast go_latest.version "1.27.3");
    maintainers = with maintainers; [ yinfeng ];
  };
}
