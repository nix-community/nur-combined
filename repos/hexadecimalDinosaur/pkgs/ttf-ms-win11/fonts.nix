rec {
  files = builtins.fromJSON (builtins.readFile ./fonts.json);
  fonts = builtins.attrNames files;
}
