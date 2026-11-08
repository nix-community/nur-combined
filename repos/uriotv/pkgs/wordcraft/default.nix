{ callPackage }:
callPackage ../../lib/artcraft {
  pname = "wordcraft";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  description = "Word processor with DOCX and ODT support";
}
