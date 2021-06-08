{ pkgs, lib, config, ... } :

with lib;
with lib.modules;
with lib.options;

let
  cfg = config;

in {
  options = {
    #
    # Defintions of tests
    #
    slurmParams = mkOption {
      description = "Options for sbatch";
      type = with types; listOf str;
      default = [];
    };

    slurm = mkOption {
      description = "Generate a slurm script instead of standard shell script";
      type = types.bool;
      default = false;
    };

    label = mkOption {
      description = "Label for test run";
      type = types.str;
    };

    benchmarks = mkOption {
      type = with types; attrsOf ( submodule ({...} : {
        options = {
          enable = mkOption {
            type = types.bool;
            description = "Enable test";
            default = true;
          };

          bench = mkOption {
            type = types.attrs;
          };

          extraSetup = mkOption {
            description = "Shell code insterted at the beginning of the script";
            type = types.lines;
            default = "";
          };

          slurmParams = mkOption {
            description = "Options for sbatch";
            type = with types; listOf str;
            default = [];
          };

          params = mkOption {
            description = "Parameters to create a benchmark for";
            type = with types; listOf attrs;
            default = [];
          };
        };
      }));
    };

    #
    # Definitons of output
    #

    # set of all generated benchmark scripts
    _out = mkOption {
      type = types.attrs;
    };
  };

  config = {
     # Create a set of benchmarks from user config
    _out = builtins.listToAttrs ( lib.flatten ( lib.mapAttrsToList (n: v: v)
      (lib.mapAttrs ( setName: setValue:
        map ( paramSet: let
            runName = # construct name from config + parameters
              concatStringsSep "-"
              (mapAttrsToList (pName: pValue: pName + (builtins.replaceStrings [" "] ["_"] (toString pValue))) paramSet);
          in {
          name = "${setName}-${runName}";
          value = if cfg.slurm then # create slurm job
            pkgs.qchem.writeScriptSlurm  {
              name = "${setName}-${runName}";
              c = if hasAttr "threads" paramSet then paramSet.threads else 1;
              n = if hasAttr "tasks" paramSet then paramSet.tasks else 1;
              J = "${setName}-${runName}";
              extraSbatch = cfg.slurmParams ++ setValue.slurmParams;
              text = ''
                # make path available for setup phase
                runScript=${setValue.bench paramSet}

                ${setValue.extraSetup}

                $runScript
              '';
            }
            else # bare script, no slurm
              setValue.bench paramSet;
        }) setValue.params ) (filterAttrs (n: v: v.enable ) cfg.benchmarks) )));
  };
}
