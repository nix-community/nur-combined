{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "cf-terraforming";
  version = "0.19.0";
  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf-terraforming";
    rev = "v${version}";
    sha256 = "sha256-eGfPk3qptNf6QfVKDT4MwJav7z+ri+eEiB7KHGRxzOE=";
  };

  vendorHash = "sha256-cWFCEC20D2nhVeW7P/w5YSt1tQbWTPDWF/eaxEvWoLo=";

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
    broken = !(versionAtLeast (versions.majorMinor trivial.version) "22.11");
    maintainers = with maintainers; [ yinfeng ];
  };
}
