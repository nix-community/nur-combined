{
  lib,
  sources,
  buildGoModule,
  sqlite,
}:

buildGoModule (finalAttrs: {
  inherit (sources.bifrost) pname version src;

  sourceRoot = "bifrost-transports-v${finalAttrs.version}/transports";

  vendorHash = "sha256-BFZdAwyET62m+qjskscTGzQI0tHdjbiRf6BFN6ICBV8=";

  env.CGO_ENABLED = 1;
  GOWORK = "off";

  tags = [ "sqlite_static" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  subPackages = [ "bifrost-http" ];

  preBuild = ''
    mkdir -p bifrost-http/ui
    cat > bifrost-http/ui/index.html << 'EOF'
    <!DOCTYPE html>
    <html><body>Bifrost Gateway</body></html>
    EOF
  '';

  buildInputs = [ sqlite ];

  doCheck = false;

  meta = {
    changelog = "https://github.com/maximhq/bifrost/releases/tag/transports/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "High-performance AI gateway with unified OpenAI-compatible API";
    homepage = "https://github.com/maximhq/bifrost";
    license = lib.licenses.asl20;
    mainProgram = "bifrost-http";
  };
})
