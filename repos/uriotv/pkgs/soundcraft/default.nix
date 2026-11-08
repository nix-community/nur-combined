{ callPackage }:
callPackage ../../lib/artcraft {
  pname = "soundcraft";
  source = builtins.fromJSON (builtins.readFile ./source.json);
  description = "Digital audio workstation";
}
