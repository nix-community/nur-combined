{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    terranix = {
      url = "github:mrVanDalo/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    terranix,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      terraform = pkgs.terraform_0_15.withPlugins (p:
        with p; [
          #libvirt
          #random
          #external
          #template
          #p."null"
        ]);

      terraformConfiguration = terranix.lib.buildTerranix {
        inherit pkgs;
        strip_nulls = false;
        terranix_config = {
          # import a config.nix and maybe other terranix flakes
          imports = [./config.nix];
          ## and or inline your terranix code
          #resource.local_file.test = {
          #  filename = "test.txt";
          #  content = "A terranix created test file. YEY!";
          #};
        };
      };
    in {
      defaultPackage = terraformConfiguration;
      # nix develop
      devShell = pkgs.mkShell {
        ENVRC = "terraform";
        buildInputs = [
          terraform
          terranix.defaultPackage.${system}
        ];
      };
      # nix run ".#apply"
      apps.apply = {
        type = "app";
        program = toString (pkgs.writers.writeBash "apply" ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          cp ${terraformConfiguration} config.tf.json \
            && ${terraform}/bin/terraform init \
            && ${terraform}/bin/terraform apply
        '');
      };
      # nix run ".#destroy"
      apps.destroy = {
        type = "app";
        program = toString (pkgs.writers.writeBash "destroy" ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          cp ${terraformConfiguration} config.tf.json \
            && ${terraform}/bin/terraform init \
            && ${terraform}/bin/terraform destroy
        '');
      };
      # nix run ".#plan"
      apps.plan = {
        type = "app";
        program = toString (pkgs.writers.writeBash "destroy" ''
          if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
          cp ${terraformConfiguration} config.tf.json \
            && ${terraform}/bin/terraform init \
            && ${terraform}/bin/terraform plan
        '');
      };
      # nix run
      defaultApp = self.apps.${system}.apply;
    })
    // (let
    in {
      # architecture agnostic attributes
    });
}
