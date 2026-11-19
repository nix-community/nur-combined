{ lib
, buildGoModule
, callPackage
}:

let
  sources = (callPackage ../../_sources/generated.nix { }).xgen;
in
buildGoModule {
  pname = "xgen";
  version = "0-unstable-${sources.date}";

  inherit (sources) src;

  vendorHash = "sha256-LYzCWLKGElGYiPm8U2hKdJfv3Q4tXrwXr6I+8dlIoMc=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "XSD (XML Schema Definition) parser and Go/C/Java/Rust/TypeScript code generator";
    homepage = "https://github.com/xuri/xgen/tree/master";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "xgen";
  };
}
