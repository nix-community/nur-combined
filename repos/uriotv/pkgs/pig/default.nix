{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:

buildGo126Module rec {
  pname = "pig";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "MichaelKinsy";
    repo = "PiG";
    rev = "v${version}";
    hash = "sha256-JmsDIQMIfIr6StkLO7IJPajenJfOotYuZ0ZZCYVzMeA=";
  };

  # The upstream project includes several unrelated Go tools in go.mod; only
  # build the standalone PiG executable and ship no runtime dependencies.
  vendorHash = "sha256-dG+bUBsTYi7yKvxBPKbLTTB/OTHQ6OTky6fQkrPIanc=";
  subPackages = [ "cmd/pig" ];
  proxyVendor = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/MichaelKinsy/PiG/internal/coding/pigversion.Version=${version}"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Pi coding agent rebuilt in Go as a single native binary";
    homepage = "https://pi-in-go.dev/";
    changelog = "https://github.com/MichaelKinsy/PiG/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "pig";
    platforms = platforms.unix;
  };
}
