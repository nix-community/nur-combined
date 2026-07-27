{ config, lib, ... }:
with lib;
let
  cfg = config.programs.git.codeberg;
in {
  options.programs.git.codeberg = let
    typeRepoConfig = types.submodule {
      options = {
        user = mkOption {
          type = types.str;
          description = "User to reference from programs.git.codeberg.users";
        };
      };
    };
    typeUserConfig = types.submodule ({ name, ... }: {
      options = {
        username = mkOption {
          type = types.str;
          description = "Codeberg user name";
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
      #default = mkIf (config.programs.git.codeberg.users != null);
      default = config.programs.git.codeberg.users != null;
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
    userRepos = mapAttrs' (name: user: nameValuePair user.username { user = name; }) cfg.users;
    repos = cfg.sharedRepos // cfg.orgs // userRepos;
    urlInsteadOf = name: config: let
      host = "codeberg-${config.user}";
    in {
      "${host}:${name}".insteadOf = ["git@codeberg.org:${name}" "ssh://git@codeberg.org/${name}"];
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
      nameValuePair "codeberg-${name}" (let
        privateKey = optional (user.sshKeyPrivate != null) user.sshKeyPrivate;
      in {
        hostname = "codeberg.org";
        user = "git";
        identitiesOnly = true;
        compression = false;
        identityFile = map toString privateKey;
      })
    ) cfg.users;
  };
}
