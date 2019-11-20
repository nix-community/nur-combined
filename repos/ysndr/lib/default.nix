{ pkgs }:

with pkgs; {

  wrap = { paths ? [], vars ? {}, file ? null, script ? null, shell ? false, name ? "wrap" }:
    assert file != null || script != null ||
          abort "wrap needs 'file' or 'script' argument";
    with rec {
      set  = n: v: "--set ${escapeShellArg (escapeShellArg n)} " +
                    "'\"'${escapeShellArg (escapeShellArg v)}'\"'";
      args = (map (p: "--prefix PATH : ${p}/bin") paths) ++
             (builtins.attrValues (builtins.mapAttrs set vars));
    };
    runCommand name
      {
        f           = if file == null then (if shell then writeShellScript else writeScript) name script else file;
        buildInputs = [ makeWrapper ];
      }
      ''
        makeWrapper "$f" "$out" ${builtins.toString args}
      '';



  collectionWith = {name, inputs, shellHook ? "", vars ? {}}:
    let
      shell = mkShell {
        name="${name}-collection";
        buildInputs=inputs;
        inherit shellHook;
        env = buildEnv {inherit name; paths = inputs;};
      } // vars;
    in if lib.inNixShell then shell else shell.env;
}
