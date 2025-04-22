{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "script-exporter";
  version = "2.22.0";

  src = fetchFromGitHub {
    owner = "ricoberger";
    repo = "script_exporter";
    rev = "v${version}";
    hash = "sha256-X4nlGrZp7g7gsveBM/590ru22APE9MCvj32YJl6AIeA=";
  };

  vendorHash = "sha256-RAdWn+La+HdJAs1jn6IxIoZ4TGcB9T3hvYAvGvEXSYU=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Prometheus exporter to execute scripts and collect metrics from the output or the exit status";
    homepage = "https://github.com/ricoberger/script_exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "script-exporter";
  };
}
