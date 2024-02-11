{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  btrfs-progs,
  gpgme,
  lvm2,
  nix-update-script,
}:

buildGoModule rec {
  pname = "prometheus-podman-exporter";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "containers";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-2BXHtrtrXMAJEN3/OuujIMykBPrEvD498vCdL0KQCX4=";
  };

  vendorHash = null;

  ldflags =
    let
      pkg = "github.com/containers/prometheus-podman-exporter";
    in
    [
      "-X ${pkg}/cmd.buildVersion=${version}"
      "-X ${pkg}/cmd.buildRevision=1"
      "-X ${pkg}/cmd.buildBranch=release-v${version}"
    ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    btrfs-progs
    gpgme
    lvm2
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Prometheus exporter for podman environments exposing containers, pods, images, volumes and networks information.";
    homepage = "https://github.com/containers/prometheus-podman-exporter";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = platforms.linux;
  };
}
