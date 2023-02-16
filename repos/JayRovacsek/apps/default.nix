{ self, system }:
let
  pkgs = self.inputs.unstable.legacyPackages.${system};
  inherit (pkgs) terraform;

  terranix-stacks = builtins.attrNames (builtins.readDir ../terranix);

  terraform-actions = builtins.foldl' (acc: stack:
    let cfg = self.packages.${system}.${stack};
    in {
      "${stack}-apply" = {
        type = "app";
        program = builtins.toString (pkgs.writers.writeBash "apply" ''
          # Remove old config.tf.json
          if [[ -e config.tf.json ]]; then
            rm -f config.tf.json
          fi

          # If terraform state exists in the stack folder, create a hardlink
          # for us to utilise
          if [[ -e terraform.tfstate ]]; then
            echo "State exists in current directory, removing it!"
            rm -f terraform.tfstate
          fi

          if [[ -e terraform.tfvars ]]; then
            echo "State exists in current directory, removing it!"
            rm -f terraform.tfvars
          fi

          if [[ -e ./terranix/${stack}/terraform.tfstate ]]; then
            echo "State exists in stack directory, utilising it!"
            ln ./terranix/${stack}/terraform.tfstate $(pwd)
          fi

          if [[ -e ./terranix/${stack}/terraform.tfvars ]]; then
            echo "Vars file exists in stack directory, utilising it!"
            ln ./terranix/${stack}/terraform.tfvars $(pwd)
          fi

          # Run the apply
          cp ${cfg} config.tf.json \
            && ${terraform}/bin/terraform init \
            && ${terraform}/bin/terraform apply -auto-approve

          # Remove the state now we're done
          if [[ -e terraform.tfstate ]]; then
            if [[ ! -e ./terranix/${stack}/terraform.tfstate ]]; then
              echo "Copying state over to the stack directory!"
              ln terraform.tfstate ./terranix/${stack}/terraform.tfstate
            fi
            echo "Removing state in current directory!"
            rm -f terraform.tfstate
          fi

          if [[ -e terraform.tfvars ]]; then
            if [[ ! -e ./terranix/${stack}/terraform.tfvars ]]; then
              echo "Copying tfvars over to the stack directory!"
              ln terraform.tfvars ./terranix/${stack}/terraform.tfvars
            fi
            echo "Removing tfvars in current directory!"
            rm -f terraform.tfvars
          fi

          # Remove old config.tf.json and if successful
          if [[ $? && -e config.tf.json ]]; then
            rm -f config.tf.json
          fi
        '');
      };

      "${stack}-plan" = {
        type = "app";
        program = builtins.toString (pkgs.writers.writeBash "plan" ''
          # Remove old config.tf.json
          if [[ -e config.tf.json ]]; then
            rm -f config.tf.json
          fi

          # If terraform state exists in the stack folder, create a hardlink
          # for us to utilise
          if [[ -e terraform.tfstate ]]; then
            echo "State exists in current directory, removing it!"
            rm -f terraform.tfstate
          fi

          if [[ -e terraform.tfvars ]]; then
            echo "State exists in current directory, removing it!"
            rm -f terraform.tfvars
          fi

          if [[ -e ./terranix/${stack}/terraform.tfstate ]]; then
            echo "State exists in stack directory, utilising it!"
            ln ./terranix/${stack}/terraform.tfstate $(pwd)
          fi

          if [[ -e ./terranix/${stack}/terraform.tfvars ]]; then
            echo "Vars file exists in stack directory, utilising it!"
            ln ./terranix/${stack}/terraform.tfvars $(pwd)
          fi

          # Run the plan
          cp ${cfg} config.tf.json \
            && ${terraform}/bin/terraform init \
            && ${terraform}/bin/terraform plan

          # Remove the state now we're done
          if [[ -e terraform.tfstate ]]; then
            if [[ ! -e ./terranix/${stack}/terraform.tfstate ]]; then
              echo "Copying state over to the stack directory!"
              ln terraform.tfstate ./terranix/${stack}/terraform.tfstate
            fi
            echo "Removing state in current directory!"
            rm -f terraform.tfstate
          fi

          if [[ -e terraform.tfvars ]]; then
            if [[ ! -e ./terranix/${stack}/terraform.tfvars ]]; then
              echo "Copying tfvars over to the stack directory!"
              ln terraform.tfvars ./terranix/${stack}/terraform.tfvars
            fi
            echo "Removing tfvars in current directory!"
            rm -f terraform.tfvars
          fi

          # Remove old config.tf.json and if successful
          if [[ $? && -e config.tf.json ]]; then
            rm -f config.tf.json
          fi
        '');
      };

      "${stack}-destroy" = {
        type = "app";
        program = builtins.toString (pkgs.writers.writeBash "destroy" ''
          # Remove old config.tf.json
          if [[ -e config.tf.json ]]; then
            rm -f config.tf.json
          fi

          # If terraform state exists in the stack folder, create a hardlink
          # for us to utilise
          if [[ -e terraform.tfstate ]]; then
            echo "State exists in current directory, removing it!"
            rm -f terraform.tfstate
          fi

          if [[ -e terraform.tfvars ]]; then
            echo "State exists in current directory, removing it!"
            rm -f terraform.tfvars
          fi

          if [[ -e ./terranix/${stack}/terraform.tfstate ]]; then
            echo "State exists in stack directory, utilising it!"
            ln ./terranix/${stack}/terraform.tfstate $(pwd)
          fi

          if [[ -e ./terranix/${stack}/terraform.tfvars ]]; then
            echo "Vars file exists in stack directory, utilising it!"
            ln ./terranix/${stack}/terraform.tfvars $(pwd)
          fi

          # Run the destroy
          cp ${cfg} config.tf.json \
            && ${terraform}/bin/terraform init \
            && ${terraform}/bin/terraform destroy

          # Remove the state now we're done
          if [[ -e terraform.tfstate ]]; then
            if [[ ! -e ./terranix/${stack}/terraform.tfstate ]]; then
              echo "Copying state over to the stack directory!"
              ln terraform.tfstate ./terranix/${stack}/terraform.tfstate
            fi
            echo "Removing state in current directory!"
            rm -f terraform.tfstate
          fi

          if [[ -e terraform.tfvars ]]; then
            if [[ ! -e ./terranix/${stack}/terraform.tfvars ]]; then
              echo "Copying tfvars over to the stack directory!"
              ln terraform.tfvars ./terranix/${stack}/terraform.tfvars
            fi
            echo "Removing tfvars in current directory!"
            rm -f terraform.tfvars
          fi

          # Remove old config.tf.json and if successful
          if [[ $? && -e config.tf.json ]]; then
            rm -f config.tf.json
          fi
        '');
      };
    } // acc) { } terranix-stacks;

in terraform-actions
