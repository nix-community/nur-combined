{
  lib,
  buildGoApplication,
  source,
}:
buildGoApplication {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  modules = ./gomod2nix.toml;

  # main.go sits at the repository root.
  subPackages = ["."];

  # Share the CGO setting with gomod2nix's dependency cache. The whole dependency set is pure Go.
  CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    # Upstream stamps the tag verbatim, leading "v" included.
    "-X main.version=${source.version}"
  ];

  postInstall = ''
    # Upstream's release tarballs and every script/cfst_*.sh helper call the binary cfst.
    ln -s CloudflareSpeedTest $out/bin/cfst

    # `-f` defaults to a bare relative "ip.txt" that loadIPRanges log.Fatal's without, so ship the ranges for users to point it at.
    install -Dm644 ip.txt ipv6.txt -t $out/share/cloudflarespeedtest

    install -Dm644 LICENSE README.md -t $out/share/doc/cloudflarespeedtest
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # `-v` fetches api.xiu2.xyz with a 10s timeout; `-h` prints the same stamped version offline, to stdout, and exits 0.
    $out/bin/CloudflareSpeedTest -h | grep -F 'CloudflareSpeedTest ${source.version}'
    $out/bin/cfst -h >/dev/null

    test -f $out/share/cloudflarespeedtest/ip.txt
    test -f $out/share/cloudflarespeedtest/ipv6.txt
    test -f $out/share/doc/cloudflarespeedtest/LICENSE

    runHook postInstallCheck
  '';

  meta = {
    description = "Test Cloudflare CDN latency and speed to find the fastest IP; also supports other CDNs and websites";
    homepage = "https://github.com/XIU2/CloudflareSpeedTest";
    changelog = "https://github.com/XIU2/CloudflareSpeedTest/releases/tag/${source.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "CloudflareSpeedTest";
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
