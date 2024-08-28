{ lib, pkgs, unstable, ... }:

let

  ## NOTE RUN aws --profile=web_dns s3 cp s3://docs-mcs.technative.eu-longhorn/managed_service_accounts.json ~/.aws/
  technative_profiles = /home/pim/.aws/managed_service_accounts.json;

  aws_accounts = [

    {
      account_id= "104144963194";
      account_name = "wasnel-main";
      customer_name = "W-A-Snel";
      disabled = "False";
      source_profile = "wasnel";
      roles= "landing_zone_devops_administrator, landing_zone_devops_user, landing_zone_finops_review, TechnativeRole";
    }

    ]
    ++ builtins.fromJSON (lib.readFile technative_profiles);

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

  # normalize_group = group : __concatStringsSep "_" (builtins.filter (x: builtins.typeOf x == "string") (__split " " (lib.strings.toLower group)));

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
      role_arn = "arn:aws:iam::${account_id}:role/landing_zone_devops_administrator";
      region = if builtins.hasAttr account_id alternative_regions then alternative_regions."${account_id}" else "eu-central-1";
      color = if builtins.hasAttr groupnorm groups && builtins.hasAttr "color" groups.${groupnorm}
         then groups.${groupnorm}.color
         else groups.default.color;
    };
in
{
  imports = [
    ../../../home-manager-modules/programs/awscli-cust.nix
  ];

  programs.awscli-cust = {
    package = unstable.awscli2;
    enable = true;
    settings = {

      "technative" = {
        aws_account_id = "technativebv";
        account_id = "technativebv";
        region = "eu-central-1";
        output = "table";
      };
    }
    // builtins.listToAttrs (builtins.map (account: {
       name = "profile ${normalize_string (account_name account)}";
       value = make_profile { account = account; group = account.customer_name; };
    }) (builtins.filter (account: show_account account) aws_accounts));

  };
}
