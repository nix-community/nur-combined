{
  pkgs,
  lib,
  helix,
  writeTextDir,
  ...
}:

let
  configDir = writeTextDir ".config/helix/config.toml" ''
    theme = "default"

    [editor]
    line-number = "relative"
    bufferline = "always"
    cursorline = true
    color-modes = true

    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"

    [editor.file-picker]
    hidden = false

    [editor.indent-guides]
    render = true
    character = "│"
  '';
in

lib.mkWrappedProgram pkgs {
  name = "toyvo-helix";
  package = helix;
  binaryName = "hx";
  inherit configDir;
  extraBinaries = [ "helix" ];
}
