{ callPackage }:
callPackage ../../lib/artcraft {
  pname = "deckcraft";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  description = "Presentation editor";
}
