{ self, ... }:
let
  inherit (self.common.terraform.globals) aws;
  inherit (aws) region tags;
  inherit (aws.iam) state-statements;
in {
  variable = {
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
  };

  terraform = {
    # TODO: ADD BACKEND HERE ONCE BOOTSTRAP'd
    required_providers = {
      aws = {
        source = "hashicorp/aws";
        version = "4.54.0";
      };
    };
  };

  provider = {
    aws = {
      inherit region;
      default_tags = { inherit tags; };
      access_key = "\${var.AWS_ACCESS_KEY}";
      secret_key = "\${var.AWS_SECRET_KEY}";
    };
  };

  resource = {
    aws_iam_policy = {
      tf-state-modifier = {
        name = "tf-state-modifier";
        description = "A policy to enable state reading and writing";
        policy = "${builtins.toJSON {
          Version = "2012-10-17";
          Statement = state-statements;
        }}";
      };
    };

    aws_iam_user = {
      deployer = {
        name = "deployer";
        path = "/system/";
      };
    };
  };
}
