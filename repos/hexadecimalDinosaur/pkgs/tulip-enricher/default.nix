{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libpcap
}:
buildGoModule (finalAttrs: {
  pname = "tulip-enricher";
  version = "1.0.1-2025.07.03.unstable";

  src = fetchFromGitHub {
    owner = "OpenAttackDefenseTools";
    repo = "tulip";
    rev = "86f62ee5a73e8080af31bb7c27b8c89e6b16d342";
    hash = "sha256-xJCesNowkPqPP+mkUykSAkN+vKuasVVqBUp8vmYWKms=";
  };

  sourceRoot = "${finalAttrs.src.name}/services/go-importer";

  vendorHash = "sha256-Od9glMG/T072nzcTOPMkgP+W8J4bdLTMAloPLde70BE=";

  buildInputs = [
    libpcap
  ];

  subPackages = [
    "cmd/enricher"
  ];

  postInstall = ''
    mv $out/bin/enricher $out/bin/tulip-enricher
  '';

  meta = {
    description = "Network analysis tool for Attack Defence CTF";
    homepage = "https://github.com/OpenAttackDefenseTools/tulip/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "tulip-enricher";
  };
})
