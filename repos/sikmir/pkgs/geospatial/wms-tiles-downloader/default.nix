{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "wms-tiles-downloader";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "lmikolajczak";
    repo = "wms-tiles-downloader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b1QaquI0s8D9MeXbUNVZpGy3u9eCjakP5BQsyoMne1A=";
  };

  vendorHash = "sha256-9ICZowuE2qBxH12bJ8nDxr/sTM0I0JSKe5YtHJsYgi0=";

  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall =
    let
      wms-tiles-downloader =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          placeholder "out"
        else
          buildPackages.wms-tiles-downloader;
    in
    ''
      installShellCompletion --cmd wms-tiles-downloader \
        --bash <(${wms-tiles-downloader}/bin/wms-tiles-downloader completion bash) \
        --fish <(${wms-tiles-downloader}/bin/wms-tiles-downloader completion fish) \
        --zsh <(${wms-tiles-downloader}/bin/wms-tiles-downloader completion zsh)
    '';

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "CLI for downloading map tiles from WMS server";
    homepage = "https://github.com/lmikolajczak/wms-tiles-downloader";
    license = lib.licenses.mit;
    mainProgram = "wms-tiles-downloader";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
