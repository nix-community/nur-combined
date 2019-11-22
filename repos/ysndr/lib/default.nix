{ pkgs }:

with pkgs; {

  wrap = { paths ? [], vars ? {}, file ? null, script ? null, shell ? false, bin ? false, name ? "wrap" }:
    assert file != null || script != null ||
          abort "wrap needs 'file' or 'script' argument";
    with rec {
      set  = n: v: "--set ${escapeShellArg (escapeShellArg n)} " +
                    "'\"'${escapeShellArg (escapeShellArg v)}'\"'";
      args = (map (p: "--prefix PATH : ${p}/bin") paths) ++
             (builtins.attrValues (builtins.mapAttrs set vars));
      destination = if bin then "/bin/${name}" else "";
    };
    runCommand name
      {
        f = if file != null then file
            else (
              if shell then writeShellScript
              else writeScript) "${name}-unwrapped" script;
        buildInputs = [ makeWrapper ];
      }
      ''
        makeWrapper "$f" "$out"${destination} ${builtins.toString args}
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
