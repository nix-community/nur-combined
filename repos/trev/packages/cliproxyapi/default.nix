{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "cliproxyapi";
  version = "8.0.52";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wIx1XCj1MxJ7jQf9Tnm0PXyL3UfjFBFLtBR5FphS9BE=";
  };

  vendorHash = "sha256-YZf38f5X+z/rICUQKHuzmZxkPH3AAap6XkIho/injVA=";

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
