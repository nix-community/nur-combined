{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  compose = list: pkgs.lib.fix (builtins.foldl' (pkgs.lib.flip pkgs.lib.extends) (self: pkgs) list);

  makeExtensible' = pkgs: list: builtins.foldl' /*op nul list*/
    (o: f: o.extend f) (pkgs.lib.makeExtensible (self: pkgs)) list;

  mkEnv = { name ? "env"
          , buildInputs ? []
    }: let name_=name; in pkgs.stdenv.mkDerivation rec {
    name = "${name_}-env";
    phases = [ "buildPhase" ];
    postBuild = "ln -s ${env} $out";
    env = pkgs.buildEnv { name = name; paths = buildInputs; };
    inherit buildInputs;
    shellHook = ''
      export ENVRC=${name_}
      source ~/.bashrc
    '';
  };
}

