{
  fetchurl,
  lib,
  buildGo127Module,
  nix-update-script,
  sqlite,
}:

buildGo127Module (finalAttrs: {
  pname = "bifrost";
  version = "2.0.0";
  src = fetchurl {
    url = "https://github.com/maximhq/bifrost/archive/refs/tags/transports/v${finalAttrs.version}.tar.gz";
    hash = "sha256-58LlOFqV6+0PCGXiq7zbxY7UogNJCxDKqph0fy3uKv8=";
  };
  sourceRoot = "bifrost-transports-v${finalAttrs.version}/transports";

  vendorHash = "sha256-tartVUBOShmwY5n7WzbK+Kyc4EmfppfrccWX2NHkxXw=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "transports/v(.*)"
    ];
  };
  meta = {
    changelog = "https://github.com/maximhq/bifrost/releases/tag/transports/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "High-performance AI gateway with unified OpenAI-compatible API";
    homepage = "https://github.com/maximhq/bifrost";
    license = lib.licenses.asl20;
    mainProgram = "bifrost-http";
  };
})
