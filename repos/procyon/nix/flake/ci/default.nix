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
          mkdir -p "$PWD/infrastructure/terraform"
          mkdir -p "$PWD/secrets/infrastructure/terraform"
          export workingDir="$PWD/infrastructure/terraform"
          export secretsDir="$PWD/secrets/infrastructure/terraform"
          readSecretString terraform-secret .ageKey > "$secretsDir/keys.txt"
        '';

        userSetupPhase = ''
          export SOPS_AGE_KEY_FILE=$secretsDir/keys.txt
          cp -r $FLAKE_REF/{infrastructure,secrets} $PWD
          export GOOGLE_CREDENTIALS=$(sops -d $PWD/secrets/infrastructure/terraform/google.json | tr -s '\n' ' ')
          terraform -chdir=$workingDir init
        '';

        priorCheckScript = ''
          terraform -chdir=$workingDir validate
          terraform -chdir=$workingDir refresh
        '';

        effectScript =
          if (herculesCI.config.repo.branch == "main")
          then "terraform -chdir=$workingDir apply -auto-approve"
          else "terraform -chdir=$workingDir plan";

        putStateScript = ''
          cd $secretsDir && find -type f -delete
        '';
      }
    );
  };
}
