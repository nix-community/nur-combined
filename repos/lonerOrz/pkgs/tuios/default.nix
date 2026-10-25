{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  ...
}:

buildGoModule (finalAttrs: {
  pname = "tuios";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "Gaurav-Gosain";
    repo = "tuios";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ss8jYuaCkivmAzbwnlPciOtR9ftsy7wAg/mNxm/WsK0=";
  };

  vendorHash = "sha256-XmpwiFkLAeCLGtM0yd+2gzX9thshUZe9XqU8VQEBz7s=";

  # Only build the main binary
  subPackages = [ "cmd/tuios" ];

  # Drop go.work so `go mod vendor` can run.
  preBuild = ''
    rm -f go.work go.work.sum
  '';

  # The build sandbox has no network, so Go cannot fetch a newer toolchain
  # there: the nixpkgs Go must be at least the go line in go.mod (1.26.6).
  # The pinned nixpkgs has 1.26.7. "local" makes a Go that is too old fail
  # with that plain message instead of a failed download.
  env.GOTOOLCHAIN = "local";

  nativeCheckInputs = [ git ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.builtBy=nix"
  ];

  meta = {
    description = "Terminal UI Operating System - a terminal multiplexer and window manager";
    homepage = "https://github.com/Gaurav-Gosain/tuios";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "tuios";
  };
})
