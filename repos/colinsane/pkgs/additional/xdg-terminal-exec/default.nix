{ writeShellScriptBin }:
writeShellScriptBin "xdg-terminal-exec" (builtins.readFile ./xdg-terminal-exec)
