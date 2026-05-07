{
  source,
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  inherit (source)
    pname
    version
    src
    ;

  cargoLock = source.cargoLock."Cargo.lock";

  checkFlags = [
    "--skip=layout::tests::dense_flowchart_keeps_mid_span_edge_reasonably_direct"
  ];

  meta = {
    description = "A fast native Rust Mermaid diagram renderer. No browser required. 500-1000x faster than mermaid-cli";
    homepage = "https://github.com/1jehuang/mermaid-rs-renderer";
    license = lib.licenses.mit;
    mainProgram = "mmdr";
  };
}
