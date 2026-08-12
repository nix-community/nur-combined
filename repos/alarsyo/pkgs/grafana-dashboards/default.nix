{callPackage}: {
  nginx = callPackage ./nginx.nix {};
  node-exporter = callPackage ./node-exporter.nix {};
}
