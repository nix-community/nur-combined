{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  installShellFiles,
}:

buildGo127Module (finalAttrs: {
  pname = "snmpdigger";
  version = "0.2.3";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kawaiipantsu";
    repo = "snmpdigger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N/6fE61KVn26/sWyJp7vwRG8MtiWGDqnqWftZV7AxP4=";
  };

  vendorHash = "sha256-xMKVh+/ninYGAXhIFM2XlLtw3xCoVeOsVhOlerUH5eI=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-X github.com/kawaiipantsu/snmpdigger/internal/version.Version=v${finalAttrs.version}"
  ];

  postInstall = ''
    installManPage packaging/*.1
  '';

  meta = {
    description = "Fancy TUI for SNMP";
    homepage = "https://github.com/umputun/snmpdigger";
    maintainers = with lib.maintainers; [ sikmir ];
    license = lib.licenses.mit;
    mainProgram = "snmpdigger";
  };
})
