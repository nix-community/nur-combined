{ pkgs, config, lib, ... }:

with lib;

let

  gen-sieve = let
    transform = match: { fileinto, parts ? [ "from" ], ... }: ''
      ${concatStringsSep "\n" (flip map parts (part: ''
        if address :domain :matches "${part}" "${match}" {
          fileinto "${fileinto}";
        }
      ''))}
    '';
  in rules:
    pkgs.writeText "before.sieve" ''
      require ["fileinto"];
      ${(concatStringsSep "\n" (mapAttrsToList transform rules))}
    '';

  cfg = config.ma27.sieve-dsl;

in

  {

    options.ma27.sieve-dsl = {

      enable = mkEnableOption "Sieve Rules";

      rules = mkOption {
        default = {};
        description = ''
          Declarative configuration for sieve rules.
        '';

        example = literalExample ''
          {
            services.dovecot2.enable = true;
            ma27.sieve.enable = true;
            ma27.sieve.rules = {
              "github.com".fileinto = "Notifications";
            };
          }
        '';

        type = types.attrsOf (types.submodule {
          options = {

            fileinto = mkOption {
              type = types.str;
              description = ''
                In which mailbox the email from the sender
                should be filed into.
              '';
            };

            parts = mkOption {
              default = [ "from" ];
              type = types.listOf (types.enum [ "from" "to" ]); # TODO enhance
              description = ''
                Which part of the email should be investigated.
              '';
            };

          };
        });
      };

    };

    config = mkIf cfg.enable {

      assertions = [
        {
          assertion = cfg.enable -> config.services.dovecot2.enable;
          message = "This module can't be used without running dovecot2 instance.";
        }
      ];

      services.dovecot2.sieveScripts.before = gen-sieve cfg.rules;

    };

  }
