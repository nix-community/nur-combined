{ config, lib, pkgs, unstable, ... }:

{

  options.dotfiles.awsstuff = {

	enable = lib.mkEnableOption "enable aws conf stuff";
   # enable = lib.mkOption {
   #   type = lib.types.nullOr lib.types.bool;
 # #    type = lib.types.bool;
   #   default = true;
   #   description = "Enable AWS conf stuff";
   # };
  };
    #  imports = [
    #    ../../../home-manager-modules/programs/awscli-cust.nix
    #  ];

   config = 

let

  cfg = config.dotfiles.awsstuff;
  technative_profiles = /home/pim/.aws/managed_service_accounts.json;
  other_profiles = /home/pim/.aws/other_accounts.json;

  aws_accounts = []
    ++ builtins.fromJSON (lib.readFile other_profiles)
    ++ builtins.fromJSON (lib.readFile technative_profiles);

  # TODO SET THESE VALS in agenix
  groups = {
    mustad_hoofcare.color = "e5a50a";
    technative.color = "9141ac";
    ddgc.color = "1c71d8";
    improvement_it.color = "1c71d8";
    dreamlines.ignore = true;
    default.color = "cccccc";
  };

  alternative_regions = {
    "221539347604" = "us-east-2";
    "925937276627" = "us-east-2";
    "556019936812" = "us-west-2";
  };
  alternative_names = {
    "076504012268" = "playground pim";
    "556019936812" = "pastbook_stefano_cutello";
  };

  normalize_string = instring : __concatStringsSep "_" (builtins.filter (x: builtins.typeOf x == "string") (__split " " (lib.strings.toLower instring)));

  account_name = account :
    if builtins.hasAttr account.account_id alternative_names then
      alternative_names."${account.account_id}"
    else
      account.account_name;

  show_account = account :
    let
      groupnorm = normalize_string account.customer_name;
    in

    if builtins.hasAttr groupnorm groups && builtins.hasAttr "ignore" groups.${groupnorm} && groups.${groupnorm}.ignore == true then false
    else true;

  make_profile = {account, group } :
    let
      groupnorm = normalize_string group;
      account_id = account.account_id;
    in
    {
      inherit group;

      source_profile = if builtins.hasAttr "source_profile" account then account.source_profile else "technative";

      role_arn = if builtins.hasAttr "use_role" account
        then "arn:aws:iam::${account_id}:role/${account.use_role}"
        else "arn:aws:iam::${account_id}:role/landing_zone_devops_administrator";

      region = if builtins.hasAttr account_id alternative_regions then
          alternative_regions."${account_id}"
        else if builtins.hasAttr "use_region" account then
          account.use_region
        else
          "eu-central-1";

      color = if builtins.hasAttr groupnorm groups && builtins.hasAttr "color" groups.${groupnorm}
         then groups.${groupnorm}.color
         else groups.default.color;
    };
in

   lib.mkIf cfg.enable {
      programs.awscli = {
      package = unstable.awscli2;
      enable = true;
      settings = {
  
        "technative" = {
          aws_account_id = "technativebv";
          account_id = "technativebv";
          region = "eu-central-1";
          output = "table";
          group = "Technative";
        };
      }
      // builtins.listToAttrs (builtins.map (account: {
         name = "profile ${normalize_string account.customer_name}-${normalize_string (account_name account)}";
         value = make_profile { account = account; group = account.customer_name; };
      }) (builtins.filter (account: show_account account) aws_accounts));
  
    };

  };


  }
