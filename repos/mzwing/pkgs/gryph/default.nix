{
  lib,
  buildGoApplication,
  source,
}:
buildGoApplication rec {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  modules = ./gomod2nix.toml;

  subPackages = ["cmd/gryph"];

  # Share the CGO setting with gomod2nix's dependency cache.
  CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/safedep/gryph/internal/version.Version=${source.version}"
    "-X github.com/safedep/gryph/internal/version.Commit=${source.version}"
  ];

  doCheck = true;

  postInstall = ''
    install -Dm644 LICENSE README.md -t $out/share/doc/gryph

    # Install agent plugins with the command placeholder intact.
    install -Dm644 \
      agent/opencode/plugin.js \
      agent/piagent/plugin.ts \
      -t $out/share/gryph
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/gryph --version | grep -F '${source.version}'
    $out/bin/gryph --help >/dev/null
    $out/bin/gryph version | grep -F 'gryph ${source.version}'

    test -f $out/share/doc/gryph/LICENSE
    test -f $out/share/doc/gryph/README.md
    test -f $out/share/gryph/plugin.js
    test -f $out/share/gryph/plugin.ts
    grep -qF '__GRYPH_COMMAND__' $out/share/gryph/plugin.js
    grep -qF '__GRYPH_COMMAND__' $out/share/gryph/plugin.ts

    runHook postInstallCheck
  '';

  meta = {
    description = "Security layer for AI coding agents";
    homepage = "https://github.com/safedep/gryph";
    changelog = "https://github.com/safedep/gryph/releases/tag/${source.version}";
    license = lib.licenses.asl20;
    mainProgram = "gryph";
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
