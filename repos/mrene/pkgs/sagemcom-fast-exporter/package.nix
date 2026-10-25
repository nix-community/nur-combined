{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  nix-update-script,
}:

buildGo127Module (finalAttrs: {
  pname = "sagemcom-fast-exporter";
  version = "0.5.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "hairyhenderson";
    repo = "sagemcom_fast_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2WXV1nzSnuhdDMoZW5/lBwrDpybP+AGTC+rOZF3Mkeg=";
  };

  vendorHash = "sha256-XpcZjcjyLV+FKqQh5RtGzB5EbYaP50n7TnnA3LZY+m0=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
    "-X github.com/prometheus/common/version.Revision=${finalAttrs.src.tag}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Prometheus exporter for Sagemcom F@st fibre hubs";
    homepage = "https://github.com/hairyhenderson/sagemcom_fast_exporter";
    changelog = "https://github.com/hairyhenderson/sagemcom_fast_exporter/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "sagemcom_fast_exporter";
  };
})
