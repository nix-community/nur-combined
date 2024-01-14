# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Sridhar Ratnakumar <srid@srid.ca>
#
# SPDX-License-Identifier: MIT

infraDir := 'infrastructure'
tfDir  := 'infrastructure/terraform'

export TF_TOKEN_app_terraform_io := if `echo $USER` == 'vscode' {
  ``
} else {
  `sops -d --extract '["token"]' secrets/infrastructure/terraform/terraform.yaml`
}

alias tfi := _terraform-init
alias tfc := _terraform-clean
alias tfs := terraform-show
alias tfp := terraform-plan
alias tfa := terraform-apply
alias tfd := terraform-destroy
alias tfr := terraform-refresh
alias tfo := terraform-outputs
alias nvf := nvfetcher-update
alias nf := nix-fmt
alias nc := nix-check
alias ni := nix-io
alias nu := nix-update

_default:
  @just --choose --unsorted --justfile {{justfile()}}

_terraform-init:
  terraform -chdir={{tfDir}} fmt
  terraform -chdir={{tfDir}} init
  terraform -chdir={{tfDir}} validate

_terraform-clean:
  rm -rf {{tfDir}}/.terraform

# show terraform state
terraform-show *args:
  terraform -chdir={{tfDir}} show {{args}}

# plan terraform config
terraform-plan *args:
  terraform -chdir={{tfDir}} plan {{args}}

# apply terraform config
terraform-apply *args:
  terraform -chdir={{tfDir}} apply {{args}}

# destroy terraform config
terraform-destroy *args:
  terraform -chdir={{tfDir}} destroy {{args}}

# refresh terraform state
terraform-refresh:
  terraform -chdir={{tfDir}} refresh

# show terraform outputs
terraform-outputs *args:
  terraform -chdir={{tfDir}} output {{args}}

# update packages with nvfetcher
nvfetcher-update:
  nix run .#devPackages/nvfetcher-self -- -o nix/pkgs/_sources

# fmt files
nix-fmt:
  nix fmt

# check flake
nix-check: (nix-fmt)
  nix flake check -L

# print inputs and outputs
nix-io:
  nix flake metadata
  nix flake show

# update nix flake
nix-update:
  nix flake update
