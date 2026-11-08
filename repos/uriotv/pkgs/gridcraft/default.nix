{ callPackage }:
callPackage ../../lib/artcraft {
  pname = "gridcraft";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  description = "Spreadsheet editor";
}
