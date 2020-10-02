{ wrapShellScriptBin, i3, jq, lib }:
wrapShellScriptBin "i3workspaceoutput" ./i3workspaceoutput.sh rec {
  depsRuntimePath = [ i3 jq ];

  meta = {
    platforms = lib.platforms.linux;
  };
}
