{ self, lib, ... }:
let
  targetDir = "modules/nixos";
  readNix = type: lib.filter (name: name != "default.nix") (lib.attrNames (builtins.readDir "${self}/${type}"));
  importNames = readNix targetDir;
  mkImports = names: baseDir: lib.map (name: "${self}/${baseDir}/${name}") names;
in
{
  imports = mkImports importNames targetDir;
}
