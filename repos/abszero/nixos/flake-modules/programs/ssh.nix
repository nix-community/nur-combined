# Options to configure authorized keys for servers and known hosts and host to
# identity file mappings for clients
{ config, lib, ... }:

let
  inherit (builtins)
    elemAt
    filter
    concatStringsSep
    mapAttrs
    attrValues
    ;
  inherit (lib)
    types
    mkOption
    mkIf
    singleton
    pipe
    concatMapStringsSep
    getAttrs
    genAttrs
    ;

  cfg = config.abszero.programs.ssh;

  mainModule = { name, config, ... }: {
    options = {
      hostNames = mkOption {
        type = with types; listOf singleLineStr;
        default = [ name ] ++ config.extraHostNames;
        description = "Host names and IPs";
      };
      extraHostNames = mkOption {
        type = with types; listOf singleLineStr;
        default = [ ];
        description = "Additional host names. No effect if hostNames is overriden";
      };
      port = mkOption {
        type = types.port;
        # Obfuscate the port. However, for a proxy server, according to
        # https://geneva.cs.umd.edu/posts/fully-encrypted-traffic/en/, this won't
        # make it less detectable by the GFW.
        default = 1337;
        description = "SSH port";
      };
      user = mkOption {
        type = with types; nullOr singleLineStr;
        default = null;
        description = "Remote user to connect to";
      };
      publicKey = mkOption {
        type = with types; nullOr singleLineStr;
        default = null;
        description = "Public key data for the host";
      };
      identityFile = mkOption {
        type = with types; nullOr singleLineStr;
        default = "~/.ssh/id_ed25519_${name}";
        description = "Identity file used to connect to host";
      };
    };
  };

  configModule = {
    modules = singleton (
      nixos:
      let
        localCfg = cfg.knownHosts.${nixos.config.networking.hostName} or null;
      in
      {
        # Add the public keys of the local host
        users.users = genAttrs (nixos.config.abszero.users.admins ++ [ "root" ]) (username: {
          openssh.authorizedKeys.keys = mkIf (localCfg != null && localCfg.publicKey != null) [
            localCfg.publicKey
          ];
        });

        # Configure SSH port of the local host
        services.openssh.ports = mkIf (localCfg != null) [ localCfg.port ];

        programs.ssh = {
          # Add known hosts
          knownHosts = mapAttrs (_: v: getAttrs [ "hostNames" "publicKey" ] v) cfg.knownHosts;
          # Configure known hosts for connection
          extraConfig = pipe cfg.knownHosts [
            attrValues
            (filter (h: h.identityFile != null))
            (concatMapStringsSep "\n" (h: ''
              Host ${concatStringsSep " " h.hostNames}
                Port ${toString h.port}
                User ${if h.user != null then h.user else elemAt nixos.config.abszero.users.admins 0}
                IdentityFile ${h.identityFile}
                IdentitiesOnly yes
            ''))
          ];
        };
      }
    );
  };
in

{
  options.abszero = {
    nixosConfigurations = mkOption {
      type = with types; attrsOf (submodule configModule);
    };
    programs.ssh.knownHosts = mkOption {
      type = with types; attrsOf (submodule mainModule);
      default = { };
      description = "Known SSH hosts";
    };
  };
}
