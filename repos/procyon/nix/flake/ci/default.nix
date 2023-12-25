# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: Ilan Joselevich <personal@ilanjoselevich.com>
#
# SPDX-License-Identifier: MIT

{ withSystem, inputs, config, ... }: {
  imports = [
    inputs.hercules-ci-effects.flakeModule
  ];

  herculesCI = herculesCI: {
    ciSystems = [ "x86_64-linux" ];

    onPush.default.outputs.effects.terraform-deploy = withSystem config.defaultEffectSystem ({ pkgs, config, hci-effects, ... }:
      hci-effects.mkEffect {
        name = "terraform-deploy";

        inputs = with pkgs; [
          age
          git
          sops
          terraform
        ];

        secretsMap.terraform-secret = "terraform-secret";

        TF_INPUT = 0;
        TF_IN_AUTOMATION = 1;
        FLAKE_REF = "${inputs.self}";

        getStateScript = ''
          echo "Secrets: Getting..."
          mkdir -p "$PWD/infrastructure/terraform"
          mkdir -p "$PWD/secrets/infrastructure/terraform"
          export workingDir="$PWD/infrastructure/terraform"
          export secretsDir="$PWD/secrets/infrastructure/terraform"
          readSecretString terraform-secret .ageKey > "$secretsDir/keys.txt"
          export SOPS_AGE_KEY_FILE=$secretsDir/keys.txt
          cp -r $FLAKE_REF/{infrastructure,secrets} $PWD
          export TF_TOKEN_app_terraform_io=$(sops -d --extract '["token"]' secrets/infrastructure/terraform/terraform.yaml)
        '';

        userSetupPhase = ''
          echo "Terraform: Initializing..."
          terraform -chdir=$workingDir init
        '';

        priorCheckScript = ''
          echo "Terraform: Validating..."
          terraform -chdir=$workingDir validate
        '';

        effectScript =
          if (herculesCI.config.repo.branch == "main")
          then ''
            echo "Terraform: Applying..."
            terraform -chdir=$workingDir apply -auto-approve
          ''
          else ''
            echo "Terraform: Planning..."
            terraform -chdir=$workingDir plan
          '';

        putStateScript = ''
          echo "Secrets: Deleting..."
          cd $secretsDir && find -type f -delete
        '';
      }
    );
  };
}
