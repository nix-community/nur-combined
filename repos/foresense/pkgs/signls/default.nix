{
  lib,
  buildGoModule,
  fetchFromGitHub,
  alsa-lib,
}:

buildGoModule rec {
  pname = "signls";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "emprcl";
    repo = "signls";
    rev = "v${version}";
    hash = "sha256-BvYgER7jPlLLbcTxQQbDLbEp4rS/flNfgWpVi6WmkyY=";
  };

  buildInputs = [ alsa-lib ];

  vendorHash = "sha256-aFIFl613xg5Pd/3JEiMdpIbslpzcKm2pv9rmQxKvFdU=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A non-linear, generative midi sequencer in the terminal :infinity";
    homepage = "https://github.com/emprcl/signls";
    license = lib.licenses.mit;
    # maintainers = with lib.maintainers; [ ];
    mainProgram = "signls";
  };
}
