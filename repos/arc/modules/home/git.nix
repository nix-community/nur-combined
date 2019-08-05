{ config, pkgs, lib, ... }: with lib; let
  cfg = config.programs.git;
  git-config-email-apply = name: user: ''
    git config user.name "${user.name}"
    git config user.email "${user.email}"
  '' + optionalString (user.signingKey != null) ''
    git config user.signingkey "${user.signingKey}"
    git config tag.forceSignAnnotated true
  '';
  git-config-email-url-match = name: user: ''
    github-${name}:*)
      NAME=${toLower name}
      break
      ;;
  '';
  git-config-email-name-match = name: user: ''
    ${toLower name})
      ${git-config-email-apply name user}
    ${if length user.aliases > 0
      then let
        aliasless = user // { aliases = []; };
        fn = alias: git-config-email-name-match alias aliasless;
      in map fn user.aliases
      else ""
    }
      ;;
  '';
  git-config-email = pkgs.writeShellScriptBin "git-config-email" ''
    set -eu

    if [[ $# -lt 1 ]]; then
      REMOTE_URLS=$(git remote -v | cut -d $'\t' -f 2 | cut -d ' ' -f 1)

      NAME=
      for REMOTE_URL in $REMOTE_URLS; do
        case $REMOTE_URL in
          ${concatStringsSep "\n" (mapAttrsToList git-config-email-url-match cfg.configEmail)}
        esac
      done
      if [[ -z $NAME ]]; then
        echo "Name could not be autodetected" >&2
        exit 1
      fi
    else
        NAME=$1
    fi

    case $NAME in
      ${concatStringsSep "\n" (mapAttrsToList git-config-email-name-match cfg.configEmail)}
      *)
        echo "Unrecognized name $NAME." >&2
        exit 1
        ;;
    esac
  '';
  userType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "git commit full name";
      };
      email = mkOption {
        type = types.str;
        description = "git commit email address";
      };
      signingKey = mkOption {
        type = types.nullOr types.str;
        description = "git-config-email GPG signing key";
        default = null;
      };
      aliases = mkOption {
        type = types.listOf types.str;
        description = "git-config-email short name aliases";
        default = [ ];
      };
    };
  };
in {
  options.programs.git = {
    configEmail = mkOption {
      type = types.attrsOf userType;
      default = { };
    };
  };

  config.home.packages = mkIf (cfg.configEmail != { }) [git-config-email];
}
