{ config, lib, ... }:
with lib;
let
  cfg = config.programs.git.sourcehut;
in {
  options.programs.git.sourcehut = let
    typeRepoConfig = types.submodule {
      options = {
        user = mkOption {
          type = types.str;
          description = "User to reference from programs.git.sourcehut.users";
        };
        owner = mkOption {
          type = types.str;
          description = "repo owner";
        };
        name = mkOption {
          type = types.str;
          description = "repo id";
        };
      };
    };
    typeUserConfig = types.submodule ({ name, ... }: {
      options = {
        username = mkOption {
          type = types.str;
          description = "sourcehut user name";
          default = name;
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
          type = types.nullOr types.path;
          description = "SSH Key";
          default = null;
        };
      };
    });
  in {
    enable = mkOption {
      type = types.bool;
      #default = mkIf (config.programs.git.sourcehut.users != null);
      default = config.programs.git.sourcehut.users != null;
    };
    users = mkOption {
      type = types.attrsOf typeUserConfig;
      default = {};
    };
    sharedRepos = mkOption {
      type = types.attrsOf typeRepoConfig;
      default = {};
    };
    /*projects = mkOption {
      type = types.attrsOf typeRepoConfig;
      default = {};
    };*/
  };

  config = let
    userRepos = mapAttrs' (name: user: nameValuePair "~${user.username}" { user = name; }) cfg.users;
    sharedRepos = mapAttrs' (name: repo: nameValuePair "~${repo.owner}/${repo.name}" { inherit (repo) user; }) cfg.sharedRepos;
    repos = sharedRepos // userRepos;
    urlInsteadOf = name: config: let
      host = "srht-${config.user}";
    in {
      "${host}:${name}".insteadOf = ["git@git.sr.ht:${name}" "ssh://git@git.sr.ht/${name}"];
    };
    urls = mapAttrsToList urlInsteadOf repos;
  in mkIf cfg.enable {
    programs.git.configEmail = mapAttrs (_: user: {
      name = if user.name != null then user.name else user.username;
      email = if user.email != null then user.email else "${user.username}@users.noreply.github.com";
      signingKey = user.signingKey;
    }) cfg.users;
    programs.git.extraConfig.url = attrsets.mergeAttrsList urls;
    programs.ssh.matchBlocks = mapAttrs' (name: user:
      nameValuePair "srht-${name}" (let
        privateKey = optional (user.sshKeyPrivate != null) user.sshKeyPrivate;
      in {
        hostname = "git.sr.ht";
        user = "git";
        identitiesOnly = true;
        compression = false;
        identityFile = map toString privateKey;
      })
    ) cfg.users;
  };
}
