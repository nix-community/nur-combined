{ wrapShellScriptBin, i3, jq }:
wrapShellScriptBin "i3workspaceoutput" ./i3workspaceoutput.sh rec {
  depsRuntimePath = [ i3 jq ];

  meta = {
    platforms = i3.meta.platforms;
  };
}
