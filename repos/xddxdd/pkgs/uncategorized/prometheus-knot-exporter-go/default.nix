{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  knot-dns,
  gnutls,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-knot-exporter-go";
  version = "3.5.3";
  src = fetchFromGitHub {
    owner = "CZ-NIC";
    repo = "knot-exporter";
    rev = "e9b4344da7f53bb38cc34928705e920b93922ca3";
    hash = "sha256-5/fD1kt31UDXnOhWvu53LkuKokxfA1BiGPvKvjBiELs=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  vendorHash = "sha256-D+D+hzTxXcWlUtkTo48ZHOKS1mn81nSX/qnNzz1FNus=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    knot-dns
    gnutls
  ];
  env.CGO_ENABLED = 1;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.gitCommit=${finalAttrs.src.rev}"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Prometheus exporter for Knot DNS written in Go";
    homepage = "https://github.com/CZ-NIC/knot-exporter";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.linux;
    mainProgram = "knot-exporter";
  };
})
