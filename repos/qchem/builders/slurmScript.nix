{ lib, writeTextFile } :

{ name
, text
, N ? 1     # No. of nodes
, n ? null  # No. of task
, c ? null  # No. of CPUs per task
, J ? null  # Job name
# extra sbatch parameters
, extraSbatch ? []
# shell to use
, shell ? "bash"
# if set will use nix-shell as script interpreter
, nixShellArgs ? null
} :

with lib;

writeTextFile {
  inherit name;
  executable = true;
  text = ''
    #!/usr/bin/env ${if nixShellArgs == null then "${shell}" else "nix-shell"}
    #${optionalString (nixShellArgs != null) "#!nix-shell -i ${shell} ${nixShellArgs}"}
    #SBATCH -J ${if (J != null) then J else name}
    #SBATCH -N ${toString N}
    #${optionalString (n != null) "SBATCH -n ${toString n}"}
    #${optionalString (c != null) "SBATCH -c ${toString c}"}
    ${lib.concatStringsSep "\n" (map (x: "#SBATCH " + x) extraSbatch)}

    ${text}
  '';
}

