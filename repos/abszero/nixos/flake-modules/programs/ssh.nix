# Options to configure authorized keys for servers and known hosts and host to
# identity file mappings for clients
{ config, lib, ... }:

let
  inherit (builtins)
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
        description = "Host names and IPs of the host";
      };
      extraHostNames = mkOption {
        type = with types; listOf singleLineStr;
        default = [ ];
        description = "Additional host names. No effect if hostNames is overriden";
      };
      publicKey = mkOption {
        type = with types; nullOr singleLineStr;
        default = null;
        description = "Public key data for the host";
      };
      identityFile = mkOption {
        type = with types; nullOr singleLineStr;
        default = "~/.ssh/id_ed25519_${name}";
      };
    };
  };

  configModule = {
    modules = singleton (
      nixos:
      let
        key = cfg.knownHosts.${nixos.config.networking.hostName}.publicKey or null;
      in
      {
        # Add the public keys to their corresponding hosts
        nix.sshServe.keys = [ key ];
        users.users = genAttrs (nixos.config.abszero.users.admins ++ [ "root" ]) (username: {
          openssh.authorizedKeys.keys = mkIf (key != null) [ key ];
        });
        # Add known hosts to every machine
        programs.ssh = {
          knownHosts = mapAttrs (_: v: getAttrs [ "extraHostNames" "publicKey" ] v) cfg.knownHosts;
          extraConfig = pipe cfg.knownHosts [
            attrValues
            (filter (h: h.identityFile != null))
            (concatMapStringsSep "\n" (h: ''
              Host ${concatStringsSep " " h.hostNames}
                IdentityFile ${h.identityFile}
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
