{ callPackage }:
callPackage ../../lib/artcraft {
  pname = "photocraft";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  description = "Layered image editor";
}
