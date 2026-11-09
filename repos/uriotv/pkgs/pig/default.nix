{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:

buildGo126Module rec {
  pname = "pig";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "MichaelKinsy";
    repo = "PiG";
    rev = "v${version}";
    hash = "sha256-hMHErCIZscyYx7pNhKXvS+DCA65SZzh9xB+B/dw1L0Q=";
  };

  # The upstream project includes several unrelated Go tools in go.mod; only
  # build the standalone PiG executable and ship no runtime dependencies.
  vendorHash = "sha256-MAF46CNhJYtJ66LnOmXTiYzS49inekoU2rH47YuLFKM=";
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
