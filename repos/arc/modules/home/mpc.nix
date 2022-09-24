{ pkgs, lib, config, ... }: with lib; let
  inherit (config.services) mpd;
  inherit (config.programs) mpc ncmpcpp;
  cfg = mpc;
  default = cfg.servers.${cfg.defaultServer};
  serverEnv = server: toString ([
    "MPD_HOST=${escapeShellArg server.out.MPD_HOST}"
  ] ++ optional (server.out.MPD_PORT != null) "MPD_PORT=${escapeShellArg server.out.MPD_PORT}"
  );
  otherServers = filterAttrs (name: server: name != cfg.defaultServer && server.enable) cfg.servers;
  aliasProgram = program: mapAttrs' (_: server: nameValuePair "${program}-${server.name}" ''
    ${serverEnv server} command ${program} "$@"
  '') otherServers;
  mpdServerModule = { config, name, ... }: {
    options = with types; {
      enable = mkEnableOption "mpd server" // {
        default = true;
      };
      name = mkOption {
        type = str;
        readOnly = true;
        default = name;
      };
      connection = mkOption {
        type = submodule ../misc/connection.nix;
      };
      password = mkOption {
        type = nullOr str;
        default = null;
      };
      out = {
        MPD_HOST = mkOption {
          type = str;
        };
        MPD_PORT = mkOption {
          type = nullOr port;
          default = null;
        };
      };
    };
    config = {
      out = let
        inherit (config.connection.binding) port;
        hasPassword = config.password != null;
      in {
        MPD_HOST = optionalString hasPassword (config.password + "@") + config.connection.host;
        MPD_PORT = mkIf config.connection.binding.explicitPort port;
      };
    };
  };
in {
  options.programs = with types; {
    mpc = {
      enable = mkEnableOption "mpc";
      package = mkOption {
        type = package;
        default = pkgs.mpc-cli;
      };
      servers = mkOption {
        type = attrsOf (submodule mpdServerModule);
        default = { };
      };
      defaultServer = mkOption {
        type = nullOr str;
        default = if cfg.servers.local.enable or false then "local" else null;
      };
    };
  };

  config = {
    programs = {
      mpc.servers.local = {
        inherit (mpd) enable;
        connection = mkIf mpd.hasBinding {
          binding = mpd.bindings.socket or mpd.bindings.network;
        };
      };
      ncmpcpp.settings = mkIf (cfg.defaultServer != null) {
        mpd_host = mkOptionDefault default.out.MPD_HOST;
        mpd_port = mkIf (default.out.MPD_PORT != null) (mkOptionDefault default.out.MPD_PORT);
      };
    };
    home = {
      packages = mkIf cfg.enable [
        cfg.package
      ];
      sessionVariables = mkIf (cfg.defaultServer != null && default.enable) {
        inherit (default.out) MPD_HOST;
        ${if (default.out.MPD_PORT != null) then "MPD_PORT" else null} = default.out.MPD_PORT;
      };
      shell.functions = mkMerge [
        (mkIf ncmpcpp.enable (aliasProgram "ncmpcpp"))
        (mkIf mpc.enable (aliasProgram "mpc"))
      ];
    };
  };
}
