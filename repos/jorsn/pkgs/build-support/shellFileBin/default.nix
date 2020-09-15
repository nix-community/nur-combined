{ writeShellScriptBin
, lib
}:

let
  setPath = inputs: lib.optionalString (builtins.length inputs > 0) ''
    PATH=${lib.makeBinPath inputs}''${PATH:+:}"$PATH"
  '';
in inputs: filePath:
  writeShellScriptBin
    (baseNameOf filePath)
    (setPath inputs + builtins.readFile filePath)
