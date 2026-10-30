{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  ...
}:

buildGoModule (finalAttrs: {
  pname = "tuios";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "Gaurav-Gosain";
    repo = "tuios";
    tag = "v${finalAttrs.version}";
    hash = "sha256-74V4F/xyDyWmJtmhIlpfSyAa0018SWw/dr2RsF4gGdM=";
  };

  vendorHash = "sha256-DtMxCwM/rv2JX72o7m5OEHVcvl+XZBgB9pvmRaPhUuU=";

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
