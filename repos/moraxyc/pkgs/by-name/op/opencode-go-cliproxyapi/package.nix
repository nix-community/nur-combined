{
  lib,
  stdenv,
  buildGoModule,

  sources,
  source ? sources.opencode-go-cliproxyapi,
}:
buildGoModule {
  inherit (source) pname version src;

  patches = [
    ./opencode-go-catalog-excluded-models.patch
  ];

  # nix-update auto
  vendorHash = "sha256-/0miMpbgZpGCTDBC6YOihrPLLcAMuBgP4+eNLxGpAn4=";
  env.CGO_ENABLED = "1";

  buildPhase = ''
    runHook preBuild

    go build -buildmode=c-shared -ldflags="-s -w" -o opencode-go-cliproxyapi${stdenv.hostPlatform.extensions.sharedLibrary} .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 opencode-go-cliproxyapi${stdenv.hostPlatform.extensions.sharedLibrary} -t "$out/lib/cliproxyapi/plugins/${stdenv.hostPlatform.go.GOOS}/${stdenv.hostPlatform.go.GOARCH}/"

    runHook postInstall
  '';

  meta = {
    description = "OpenCode Go provider plugin for CLIProxyAPI";
    homepage = "https://github.com/massiveits/opencode-go-cliproxyapi";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
