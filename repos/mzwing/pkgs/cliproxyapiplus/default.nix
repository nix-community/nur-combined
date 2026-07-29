{
  lib,
  stdenv,
  buildGoModule,
  source,
  makeWrapper,
  xdg-utils,
}:
buildGoModule rec {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  vendorHash = "sha256-lERAJk7yzjI5yjXQmXL6iRv3C6yZgfCKkDaLjrnId0o=";

  subPackages = ["cmd/server"];

  env.CGO_ENABLED = "1";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}-plus"
  ];

  doCheck = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [makeWrapper];

  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api-plus

    install -Dm644 \
      LICENSE \
      README.md \
      README_CN.md \
      README_JA.md \
      README-ccs-fork.md \
      config.example.yaml \
      -t $out/share/doc/cliproxyapiplus
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/cli-proxy-api-plus \
      --prefix PATH : ${lib.makeBinPath [xdg-utils]}
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    help="$($out/bin/cli-proxy-api-plus --help 2>&1)"
    echo "$help" | grep -F 'CLIProxyAPI Version: ${version}-plus'
    echo "$help" | grep -F 'Usage of'

    test -f $out/share/doc/cliproxyapiplus/LICENSE
    test -f $out/share/doc/cliproxyapiplus/README.md
    test -f $out/share/doc/cliproxyapiplus/config.example.yaml

    runHook postInstallCheck
  '';

  meta = {
    description = "Proxy server providing OpenAI, Gemini, Claude, Codex, and Grok compatible APIs for AI CLIs";
    homepage = "https://github.com/kaitranntt/CLIProxyAPIPlus";
    changelog = "https://github.com/kaitranntt/CLIProxyAPIPlus/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "cli-proxy-api-plus";
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
