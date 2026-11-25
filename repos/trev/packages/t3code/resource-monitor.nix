{
  rustPlatform,
  t3code-unwrapped,
}:

rustPlatform.buildRustPackage {
  pname = "t3code-resource-monitor";
  inherit (t3code-unwrapped) version src;

  sourceRoot = "${t3code-unwrapped.src.name}/native/resource-monitor";

  cargoHash = "sha256-deTy3FFcOwhxZnEbWDXFGVFFoKUex434ADJQtchVzbs=";

  meta = {
    description = "Native resource diagnostics sidecar for T3 Code";
    inherit (t3code-unwrapped.meta)
      homepage
      changelog
      license
      platforms
      ;
    mainProgram = "t3-resource-monitor";
  };
}
