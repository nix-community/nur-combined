{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "fztea";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "jon4hz";
    repo = "fztea";
    rev = "v${version}";
    hash = "sha256-Qjb5j0G49b/gomC4eWid/5zmlMFk4ufHhuRNkI5X0l4=";
  };

  vendorHash = "sha256-eDQHX7sXsHT8Hhg/U+NrD+VYZ/DRfTz5KeAOi4vD+/k=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jon4hz/fztea/internal/version.Version=${version}"
  ];

  meta = with lib; {
    description = "Remote control your flipper from the local terminal or over SSH";
    homepage = "https://github.com/jon4hz/fztea";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
    mainProgram = "fztea";
  };
}
