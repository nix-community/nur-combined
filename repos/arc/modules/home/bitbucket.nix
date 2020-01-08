{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.git.bitbucket;
in {
  options.programs.git.bitbucket = let
    typeRepoConfig = types.submodule {
      options = {
        user = mkOption {
          type = types.str;
          description = "User to reference from programs.git.bitbucket.users";
        };
      };
    };
    typeUserConfig = types.submodule ({ name, ... }: {
      options = {
        username = mkOption {
          type = types.str;
          description = "Bitbucket user name";
          default = name;
        };
        id = mkOption {
          type = types.nullOr types.str;
          description = "Bitbucket user ID";
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
          type = types.nullOr (types.either types.path types.str);
          description = "SSH Key";
          default = null;
        };
        sshKeyPublic = mkOption {
          type = types.nullOr (types.either types.path types.str);
          description = "SSH Key";
          default = null;
        };
      };
    });
  in {
    enable = mkOption {
      type = types.bool;
      #default = mkIf (config.programs.git.bitbucket.users != null);
      default = config.programs.git.bitbucket.users != null;
    };
    users = mkOption {
      type = types.attrsOf typeUserConfig;
      default = {};
    };
    sharedRepos = mkOption {
      type = types.attrsOf typeRepoConfig;
      default = {};
    };
    teams = mkOption {
      type = types.attrsOf typeRepoConfig;
      default = {};
    };
  };

  config = let
    userRepos = mapAttrs (name: _: { user = name; }) cfg.users;
    repos = cfg.sharedRepos // cfg.teams // userRepos;
    urlInsteadOf = name: config: let
      host = "bitbucket-${config.user}";
    in {
      "${host}:${name}".insteadOf = ["git@bitbucket.org:${name}" "ssh://git@bitbucket.org/${name}"];
    };
    urls = mapAttrsToList urlInsteadOf repos;
  in mkIf cfg.enable {
    programs.git.configEmail = mapAttrs (_: user: {
      name = if user.name != null then user.name else user.username;
      email = if user.email != null then user.email else "${user.username}@users.noreply.github.com";
      signingKey = user.signingKey;
    }) cfg.users;
    programs.git.extraConfig.url = pkgs.lib.foldAttrList urls;
    programs.ssh.matchBlocks = mapAttrs' (name: user:
      nameValuePair "bitbucket-${name}" (let
        privateKey = optional (user.sshKeyPrivate != null) (pkgs.arc.lib.asFile "bitbucket-${name}-key" user.sshKeyPrivate);
      in {
        hostname = "bitbucket.org";
        user = "git";
        identitiesOnly = true;
        compression = false;
        identityFile = map toString privateKey;
      })
    ) cfg.users;
  };
}
