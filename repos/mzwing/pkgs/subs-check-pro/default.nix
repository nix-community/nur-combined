{
  lib,
  buildGoApplication,
  source,
}:
buildGoApplication rec {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  modules = ./gomod2nix.toml;

  # main.go sits at the repository root.
  subPackages = ["."];

  # Share the CGO setting with gomod2nix's dependency cache. Upstream builds every release
  # target with cgo off (.goreleaser.yaml, Makefile).
  CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    # Upstream stamps a short commit here and prints "<version>-<commit>" on startup.
    # nvfetcher pins by tag, so there is no commit to stamp.
    "-X main.CurrentCommit=nix"
  ];

  postInstall = ''
    install -Dm644 \
      LICENSE \
      README.md \
      config/config.yaml.example \
      -t $out/share/doc/subs-check-pro
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # There is no --version and no run-once mode: an argument-less invocation starts the
    # scheduler and never returns. `-h` is the only terminating entry point, and Go's flag
    # package prints usage to stderr and exits non-zero.
    help="$($out/bin/subs-check-pro -h 2>&1 || true)"
    echo "$help" | grep -F -- '-f string'

    test -f $out/share/doc/subs-check-pro/config.yaml.example

    runHook postInstallCheck
  '';

  meta = {
    description = "High-performance proxy subscription checker: liveness, speed and streaming-unlock tests, encoding the results into node names";
    homepage = "https://github.com/sinspired/subs-check-pro";
    changelog = "https://github.com/sinspired/subs-check-pro/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "subs-check-pro";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
