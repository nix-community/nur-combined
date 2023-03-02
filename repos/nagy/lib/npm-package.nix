{ pkgs, ... }:
let name = "gltf-pipeline"; in
pkgs.runCommandLocal name {
  pname = name;
  version = "latest";
  dontUnpack = true;
  nativeBuildInputs = [ pkgs.nodejs ];
  buildInputs = [ pkgs.nodejs ];
  NPM_CONFIG_CACHE = "/tmp";
  NPM_CONFIG_PREFIX = placeholder "out";
} "npm install --global $pname@$version"
