{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.git.gitHub;
  arc = import ../../canon.nix { inherit pkgs; };
in {
  options.programs.git.gitHub = let
    typeRepoConfig = types.submodule {
      options = {
        user = mkOption {
          type = types.str;
          description = "User to reference from programs.git.gitHub.users";
        };
      };
    };
    typeUserConfig = types.submodule {
      options = {
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
          type = types.nullOr types.path;
          description = "SSH Key";
          default = null;
        };
        keysHash = mkOption {
          type = types.str;
          description = "Fixed-output derivation hash";
        };
      };
    };
  in {
    enable = mkOption {
      type = types.bool;
      #default = mkIf (config.programs.git.gitHub.users != null);
      default = config.programs.git.gitHub.users != null;
    };
    users = mkOption {
      type = types.attrsOf typeUserConfig;
      default = {};
    };
    sharedRepos = mkOption {
      type = types.attrsOf typeRepoConfig;
      default = {};
    };
    orgs = mkOption {
      type = types.attrsOf typeRepoConfig;
      default = {};
    };
  };

  config = let
    userRepos = mapAttrs (name: _: { user = name; }) cfg.users;
    repos = cfg.sharedRepos // cfg.orgs // userRepos;
    urlInsteadOf = name: config: let
      host = "github-${config.user}";
    in {
      "${host}:${name}".insteadOf = ["git@github.com:${name}" "ssh://git@github.com/${name}"];
    };
    urls = mapAttrsToList urlInsteadOf repos;
  in mkIf cfg.enable {
    programs.git.configEmail = mapAttrs (name: user: {
      name = if user.name != null then user.name else name;
      email = if user.email != null then user.email else "${name}@users.noreply.github.com";
      signingKey = user.signingKey;
    }) cfg.users;
    programs.git.extraConfig.url = arc.lib.foldAttrList urls;
    programs.ssh.matchBlocks = mapAttrs' (name: user:
      nameValuePair "github-${name}" (let
        privateKey = optional (user.sshKeyPrivate != null) user.sshKeyPrivate;
      in {
        hostname = "github.com";
        user = "git";
        identitiesOnly = true;
        compression = false;
        identityFile = map toString privateKey;
      })
    ) cfg.users;
  };
}
