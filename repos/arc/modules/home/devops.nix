{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.git.devops;
  arc = import ../../canon.nix { inherit pkgs; };
in {
  options.programs.git.devops = let
    typeRepoConfig = types.submodule {
      options = {
        id = mkOption {
          type = types.str;
          description = "Domain ID";
        };
        domain = mkOption {
          type = types.str;
          description = "Domain name";
        };
        user = mkOption {
          type = types.str;
          description = "User to reference from programs.git.devops.users";
        };
      };
    };
    typeUserConfig = types.submodule ({ name, ... }: {
      options = {
        username = mkOption {
          type = types.nullOr types.str;
          description = "Microsoft user name";
          default = null;
        };
        name = mkOption {
          type = types.nullOr types.str;
          description = "git commit name";
          default = null;
        };
        email = mkOption {
          type = types.nullOr types.str;
          description = "git commit email address";
          default = null;
        };
        signingKey = mkOption {
          type = types.nullOr types.str;
          description = "GPG signing key";
          default = null;
        };
        sshKeyPrivate = mkOption {
          type = types.nullOr types.path;
          description = "SSH Key";
          default = null;
        };
        sshKeyPublic = mkOption {
          type = types.nullOr types.str;
          description = "SSH Key";
          default = null;
        };
      };
    });
  in {
    enable = mkOption {
      type = types.bool;
      default = config.programs.git.devops.users != null;
    };
    users = mkOption {
      type = types.attrsOf typeUserConfig;
      default = {};
    };
    teams = mkOption {
      type = types.attrsOf typeRepoConfig;
      default = {};
    };
  };

  config = let
    userRepos = mapAttrs' (name: user: nameValuePair user.username { user = name; }) cfg.users;
    repos = cfg.teams // userRepos;
    urlInsteadOf = name: config: let
      host = "devops-${config.user}";
    in {
      "${host}:v3/${name}".insteadOf = ["${name}@vs-ssh.visualstudio.com:v3/${name}" "ssh://${name}@vs-ssh.visualstudio.com/v3/${name}"];
    };
    urls = mapAttrsToList urlInsteadOf repos;
  in mkIf cfg.enable {
    programs.git.configEmail = mapAttrs (_: user: {
      name = if user.name != null then user.name else user.username;
      email = if user.email != null then user.email else "${user.username}@users.noreply.github.com";
      signingKey = user.signingKey;
    }) cfg.users;
    programs.git.extraConfig.url = arc.lib.foldAttrList urls;
    programs.ssh.matchBlocks = mapAttrs' (name: user:
      nameValuePair "devops-${name}" (let
        privateKey = optional (user.sshKeyPrivate != null) user.sshKeyPrivate;
      in {
        hostname = "vs-ssh.visualstudio.com";
        user = name;
        identitiesOnly = true;
        compression = false;
        identityFile = map toString privateKey;
        extraOptions = {
          HostkeyAlgorithms = "+ssh-rsa";
          PubkeyAcceptedAlgorithms = "+ssh-rsa";
        };
      })
    ) cfg.users;
  };
}
