{
  lib,
  buildGoApplication,
  source,
}:
buildGoApplication {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  modules = ./gomod2nix.toml;

  # main.go sits at the repository root; android/ is a Gradle wrapper, not Go.
  subPackages = ["."];

  # Share the CGO setting with gomod2nix's dependency cache. The whole dependency set is pure Go.
  CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    # Upstream stamps the tag verbatim, leading "v" included.
    "-X main.Version=${source.version}"
  ];

  # goCheckHook's getGoDirs honours subPackages, which would narrow the run to the root package, the one package without tests.
  preCheck = "unset subPackages";

  postInstall = ''
    install -Dm644 LICENSE README.md README_CN.md -t $out/share/doc/cloudflarewarpspeedtest
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # `-h` exits 2 and prints no version; `-v` prints the stamped one to stdout and exits 0 without touching the network.
    $out/bin/CloudflareWarpSpeedTest -v | grep -F '${source.version}'

    test -f $out/share/doc/cloudflarewarpspeedtest/LICENSE

    runHook postInstallCheck
  '';

  meta = {
    description = "Test latency and packet loss of Cloudflare WARP IPs and ports to find the fastest endpoints";
    homepage = "https://github.com/puzige/CloudflareWarpSpeedTest";
    changelog = "https://github.com/puzige/CloudflareWarpSpeedTest/releases/tag/${source.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "CloudflareWarpSpeedTest";
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
