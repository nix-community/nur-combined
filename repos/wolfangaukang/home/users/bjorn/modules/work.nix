{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (inputs) self;
  inherit (pkgs.stdenv) hostPlatform;

  cfg = config.personaj.work;

  firefoxSettings = import "${self}/home/users/bjorn/settings/firefox" { inherit config lib pkgs; };
  ssmServersInfo = lib.importJSON "${self}/home/users/bjorn/misc/ssm.json";

  generateSSMConnectionString =
    target: profile: region:
    "sh -c \"aws ssm start-session --target ${target} --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile=${profile} --region=${region}\"";

  ssmSettings =
    let
      identityFile = "${config.home.homeDirectory}/.ssh/Keys/devices/servers";
    in
    lib.attrsets.mapAttrs (
      name: value:
      let
        profile = value.profile;
        region = value.region;
        target = value.target;
        user = value.user;
      in
      {
        inherit identityFile user;
        proxyCommand = generateSSMConnectionString target profile region;
      }
    ) ssmServersInfo;

in
{
  imports = (lib.optionals hostPlatform.isLinux [ "${self}/home/profiles/programs/keybase.nix" ]);

  options.personaj.work.simplerisk.enable = lib.mkEnableOption "the SimpleRisk profile";

  config = lib.mkIf cfg.simplerisk.enable {
    home.packages =
      with pkgs;
      [
        # GUI
        remmina

        # CLI
        awscli2
        aws-mfa
        ssm-session-manager-plugin
      ]
      ++ (lib.optionals hostPlatform.isLinux [
        gnome-screenshot
        slack
      ]);
    programs = {
      firefox.profiles = lib.mkForce (
        firefoxSettings.defaultProfiles // { work = firefoxSettings.profiles.simplerisk; }
      );
      ssh = {
        enable = true;
        matchBlocks = ssmSettings;
      };
    };
  };
}
