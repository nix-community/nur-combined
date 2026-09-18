{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "cliproxyapi";
  version = "7.3.7";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zi9nPnD/6+5Zk/KmKTH0LWgcbiqZkp7100yA8tZNlps=";
  };

  vendorHash = "sha256-r3yWkdMcM40G9jV7MxW/qNv3E9WrHavFilW24quEf+8=";

  subPackages = [ "cmd/server" ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${finalAttrs.version}"
  ];

  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Proxy server providing OpenAI-compatible APIs for CLI models";
    mainProgram = "cli-proxy-api";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    changelog = "https://github.com/router-for-me/CLIProxyAPI/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
