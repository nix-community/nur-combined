{ self, system, ... }:
let
  linodeRegion = "ap-southeast";
  awsRegion = "ap-southeast-2";
  pkgs = self.inputs.unstable.legacyPackages.${system};
  name = "csgo";
  label = name;
  group = name;
  dns = "noobhealthyfuns.com";
  servername = "Noob Healthy Funs!";
  disabled = "Disabled";
  enabled = "Enabled";
  # Magic number from here:
  # curl -k https://api.linode.com/v4/linode/stackscripts -H 'X-Filter: {"label": {"+contains": "CS:GO"}}' -H "Content-Type: application/json" | jq '.data | .[] | .label,.id'
  scriptId = 401700;

  # Went to add this via data search so we don't have magic numbers, but seems no 
  # option exists that is good here...
  hostedZoneId = "Z07293822L0ODVN4UL1I4";
in {
  variable = {
    LINODE_TOKEN = {
      type = "string";
      description = "Linode API token";
      nullable = false;
      sensitive = true;
    };
    RCON_PASSWORD = {
      type = "string";
      description = "Instance RCON Password";
      nullable = false;
      sensitive = true;
    };
    GAME_SERVER_TOKEN = {
      type = "string";
      description = "Instance GAME_SERVER_TOKEN Password";
      nullable = false;
      sensitive = true;
    };
    AWS_ACCESS_KEY = {
      type = "string";
      description = "AWS Access key";
      nullable = false;
      sensitive = true;
    };
    AWS_SECRET_KEY = {
      type = "string";
      description = "AWS Secret key";
      nullable = false;
      sensitive = true;
    };
    ROOT_PASSWORD = {
      type = "string";
      description = "Instance root password";
      nullable = false;
      sensitive = true;
    };
  };

  terraform.required_providers = {
    linode = {
      source = "linode/linode";
      version = "1.30.0";
    };
    aws = {
      source = "hashicorp/aws";
      version = "4.54.0";
    };
  };

  provider = {
    aws = {
      region = awsRegion;
      access_key = "\${var.AWS_ACCESS_KEY}";
      secret_key = "\${var.AWS_SECRET_KEY}";
    };

    linode = { token = "\${var.LINODE_TOKEN}"; };
  };

  data.linode_stackscript.${name}.id = scriptId;

  resource = {
    linode_instance.${name} = {
      inherit label group;

      # Linode don't support my key format. :sadpanda: back to ssh'in as root! :shipit:
      # authorized_keys = self.common.base-users.jay.openssh.authorizedKeys.keys;

      root_pass = "\${var.ROOT_PASSWORD}";
      region = linodeRegion;
      image = "\${data.linode_stackscript.${name}.images.0}";
      tags = [ name ];
      type = "g6-standard-2";
      stackscript_id = scriptId;
      stackscript_data = {
        inherit servername;
        gslt = "\${var.GAME_SERVER_TOKEN}";
        motd = servername;
        rconpassword = "\${var.GAME_SERVER_TOKEN}";
        svpassword = "";
        autoteambalance = disabled;
        roundtime = "5";
        maxrounds = "15";
        buyanywhere = disabled;
        friendlyfire = enabled;
      };

      provider = "linode";
    };

    aws_route53_record.${name} = {
      zone_id = hostedZoneId;
      name = dns;
      type = "A";
      ttl = 300;
      records = [ "\${resource.linode_instance.${name}.ip_address}" ];

      provider = "aws";
    };
  };
}
