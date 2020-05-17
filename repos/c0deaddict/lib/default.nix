{ pkgs }:

with pkgs.lib; {

  # http://chriswarbo.net/projects/nixos/useful_hacks.html#wrapping-binaries
  wrap = { name, paths ? [], vars ? {}, file ? null, script ? null }:
    assert file != null || script != null ||
        abort "wrap needs 'file' or 'script' argument";
    let
      set  = n: v: "--set ${escapeShellArg (escapeShellArg n)} " +
                     "'\"'${escapeShellArg (escapeShellArg v)}'\"'";

      args = (map (p: "--prefix PATH : ${p}/bin") paths) ++
             (attrValues (mapAttrs set vars));

      scriptPkg = pkgs.writeScriptBin name (
        if script == null
        then builtins.readFile file
        else script
      );
    in
      pkgs.symlinkJoin {
        inherit name;
        paths = [ scriptPkg ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/${name} ${toString args}
        '';
      };

}
