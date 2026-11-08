{ callPackage }:
callPackage ../../lib/artcraft {
  pname = "filmcraft";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  description = "Non-linear video editor";
}
