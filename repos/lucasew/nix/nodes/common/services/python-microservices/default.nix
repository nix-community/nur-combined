{ pkgs, lib, config, ... }:

let
  cfg = config.services.python-microservices;
in

{
  options = {
    services.python-microservices = {
      socketDirectory = lib.mkOption {
        description = "Where to store unix sockets to access the services";
        type = lib.types.path;
        default = "/run/python-microservices";
      };
      templateScript = lib.mkOption {
        description = "Base script where the unit script is prepended";
        type = lib.types.lines;
        default = builtins.readFile ./template.py;
      };
      services = lib.mkOption {
        description = "Python microservices that are waken up on invocation and do one thing";
        type = lib.types.attrsOf (lib.types.submodule ({name, config, ...}: {
          options = {
            enable = (lib.mkEnableOption "microservice") // {
              default = true;
            };
            name = lib.mkOption {
              readOnly = true;
              internal = true;
              type = lib.types.str;
              default = name;
            };
            unitName = lib.mkOption {
              readOnly = true;
              internal = true;
              type = lib.types.str;
              default = "python-microservices-${config.name}";
            };
            entrypoint = lib.mkOption {
              readOnly = true;
              internal = true;
              type = lib.types.path;
              default = pkgs.writeText config.unitName (lib.concatStringsSep "\n" [
                config.script
                (builtins.readFile ./template.py)
              ]);
            };
            python = (lib.mkPackageOption pkgs "python3" {})
            #  // {
            #   description = "Which python interpreter to use for this microservice. Use python.withPackages to add packages in scope.";
            # }
            ;
            script = lib.mkOption {
              description = ''
                Script code that has a handle function that returns a function that gets the `self` argument of http.server.BaseHTTPHandler

                The outer function must initialize the environment and return a function that handles each request. As services are expected to normally have only one route this is OK.

                Request data can be read from self.rfile and result data can be written to self.wfile.
              '';
              type = lib.types.lines;
              default = builtins.readFile ./default.py;
            };
          };
        }));
      };
    };
  };

  config = {
      systemd = lib.mkMerge (lib.pipe cfg.services [
        (builtins.attrValues)
        (map (item: {
          sockets.${item.unitName} = {
            socketConfig = {
              ListenStream = "${cfg.socketDirectory}/${item.name}";
            };
            partOf = [ "${item.unitName}.service" ];
            wantedBy = [ "sockets.target" "multi-user.target" ];
          };
          services.${item.unitName} = {
            script = ''
              exec ${lib.getExe item.python} ${item.entrypoint};
            '';
            unitConfig = {
              After = [ "network.target" ];
            };
            serviceConfig = {
              Nice = 7;
              PrivateTmp = true;
            };
          };

          tmpfiles.rules = [
            "d ${cfg.socketDirectory} 755 root root 0"
          ];
      }))
    ]);
  };
    
    # {
    #   systemd.sockets = lib.pipe cfg.services [
    #     (builtins.attrValues)
    #     (map (item: {
    #       name = item.unitName;
    #       value = {
    #         socketConfig = {
    #           ListenStream = "${cfg.socketDirectory}/${item.name}";
    #         };
    #         partOf = [ "${item.unitName}.service" ];
    #         wantedBy = [ "sockets.target" "multi-user.target" ];
    #       };
    #     }))
    #     (lib.listToAttrs)
    #   ];
    #   systemd.services = lib.pipe cfg.services [
    #     (builtins.attrValues)
    #     (map (item: {
    #       name = item.unitName;
    #       value = {
    #         script = ''
    #           exec ${lib.getExe item.python} ${item.entrypoint};
    #         '';
    #         unitConfig = {
    #           After = [ "network.target" ];
    #         };
    #         serviceConfig = {
    #           Nice = 7;
    #           PrivateTmp = true;
    #         };
    #       };
    #     }))
    #     (lib.listToAttrs)
    #   ];
    #   systemd.tmpfiles.rules = [
    #     "d ${cfg.socketDirectory} 755 root root 0"
    #   ];
    # };
}
