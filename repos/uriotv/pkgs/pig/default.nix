{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# buildGoModule follows nixpkgs' default Go: upstream raises its minimum Go
# (0.8.0 needs 1.27), and a pinned buildGo1xxModule falls behind.
buildGoModule rec {
  pname = "pig";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "MichaelKinsy";
    repo = "PiG";
    rev = "v${version}";
    hash = "sha256-vzwrBJDEyxj0gZNePPeIbzhkq7cmPEAoNlc1hwpH85Q=";
  };

  # The upstream project includes several unrelated Go tools in go.mod; only
  # build the standalone PiG executable and ship no runtime dependencies.
  vendorHash = "sha256-nGPTBFNAqX66XM8whZVAPdhnLmOkrddia8Buc8qvg3M=";
  subPackages = [ "cmd/pig" ];
  proxyVendor = true;

  # The release version is a constant in pigversion since 0.8.0; an -X override
  # of it would be silently ignored.
  ldflags = [
    "-s"
    "-w"
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
