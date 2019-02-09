{ pkgs }:

with pkgs; {
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
