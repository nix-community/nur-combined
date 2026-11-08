{ callPackage }:
callPackage ../../lib/artcraft {
  pname = "pdfcraft";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  description = "PDF viewer and editor";
}
