{
  fetchurl,
  lib,
  buildGo127Module,
  nix-update-script,
  sqlite,
}:

buildGo127Module (finalAttrs: {
  pname = "bifrost";
  version = "2.6.0";
  src = fetchurl {
    url = "https://github.com/maximhq/bifrost/archive/refs/tags/transports/v${finalAttrs.version}.tar.gz";
    hash = "sha256-gUPDTUk6W8ZPnpv+giilnxSInryvIyf2FNrFqZiLzzc=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  sourceRoot = "bifrost-transports-v${finalAttrs.version}/transports";

  postPatch = ''
    substituteInPlace go.mod --replace-fail "go 1.27.4" "go 1.27.3"
    grep -oP '^\t\Kgithub\.com/maximhq/bifrost/\S+' go.mod | sort -u | while read -r mod; do
      printf 'replace %s => ../%s\n' "$mod" "''${mod#github.com/maximhq/bifrost/}" >> go.mod
      substituteInPlace "../''${mod#github.com/maximhq/bifrost/}/go.mod" --replace-fail "go 1.27.4" "go 1.27.3"
    done
  '';

  vendorHash = "sha256-9nX4yeV/y5KGux6DdBHuVBW4IA3JPJ0bluHeJe10JzE=";

  env.CGO_ENABLED = 1;
  env.GOWORK = "off";

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
