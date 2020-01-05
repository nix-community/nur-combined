{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption mkIf types filterAttrs;
  inherit (pkgs.callPackage ./to-toml {}) toTOML;

  cfg =
    config.services.hercules-ci-agent;
in
{
  imports = [
    ./gc.nix
  ];

  options.services.hercules-ci-agent = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "If true, run the agent as a system service";
    };
    baseDirectory = mkOption {
      type = types.path;
      default = "/var/lib/hercules-ci-agent";
      description = "State directory (secrets, work directory, etc) for agent";
    };
    user = mkOption {
      description = "Unix system user that runs the agent service";
      type = types.str;
    };
    package = let
      version = "0.6.1";
    in
      mkOption {
        description = "Package containing the bin/hercules-ci-agent program";
        type = types.package;
        default = (import (builtins.fetchTarball "https://github.com/hercules-ci/hercules-ci-agent/archive/hercules-ci-agent-${version}.tar.gz") {}).hercules-ci-agent;
        defaultText = "hercules-ci-agent-${version}";
      };
    extraOptions = mkOption {
      description = ''
        This lets you can add extra options to the agent's config file, in case
        you are using an upstreamed module with a newer version of the package.

        These will override the other options in this module.

        We recommend that you use the other options where possible, because
        extraOptions can not provide a merge function for the contents of the
        fields.
      '';
      type = types.attrsOf types.unspecified;
      default = {};
    };

    concurrentTasks = mkOption {
      description = "Number of tasks to perform simultaneously, such as evaluations, derivations";
      type = types.int;
      default = 4;
    };

    /*
      Internal and/or computed values
     */
    fileConfig = mkOption {
      type = types.attrsOf types.unspecified;
      readOnly = true;
      internal = true;
      description = ''
        The fully assembled config file as an attribute set, right before it's
        written to file.
      '';
    };
    effectiveConfig = mkOption {
      type = types.attrsOf types.unspecified;
      readOnly = true;
      internal = true;
      description = ''
        The fully assembled config file as an attribute set plus some derived defaults.
      '';
    };
    tomlFile = mkOption {
      type = types.path;
      readOnly = true;
      internal = true;
      description = ''
        The fully assembled config file.
      '';
    };
    secretsDirectory = mkOption {
      type = types.path;
      readOnly = true;
      internal = true;
      description = ''
        Secrets directory derived from baseDirectory.
      '';
    };
    # TODO: expose all file and directory locations as readOnly options
  };

  config = mkIf cfg.enable {
    services.hercules-ci-agent = {
      secretsDirectory = cfg.baseDirectory + "/secrets";
      tomlFile = pkgs.writeText "hercules-ci-agent.toml"
        (toTOML cfg.fileConfig);

      fileConfig = filterAttrs (k: v: k == "binaryCachesPath" -> v != null) (
        {
          inherit (cfg) concurrentTasks baseDirectory;
        }
        // cfg.extraOptions
      );
      effectiveConfig =
        let
          # recursively compute the effective configuration
          effectiveConfig = defaults // cfg.fileConfig;
          defaults = {
            workDirectory = effectiveConfig.baseDirectory + "/work";
            staticSecretsDirectory = effectiveConfig.baseDirectory + "/secrets";
            clusterJoinTokenPath = effectiveConfig.staticSecretsDirectory + "/cluster-join-token.key";
            binaryCachesPath = effectiveConfig.staticSecretsDirectory + "/binary-caches.json";
          };
        in
          effectiveConfig;
    };
  };
}
