# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

infraDir := 'infrastructure'
tfDir  := 'infrastructure/terraform'

GOOGLE_CREDENTIALS := `sops -d secrets/infrastructure/terraform/google.json | tr -s '\n' ' '`

alias tfi := _terraform-init
alias tfc := _terraform-clean
alias tfs := terraform-show
alias tfp := terraform-plan
alias tfa := terraform-apply
alias tfd := terraform-destroy
alias tfr := terraform-refresh
alias tfo := terraform-outputs

[private]
default:
    @just --choose --unsorted --justfile {{justfile()}} --list-heading ''

_terraform-init:
    terraform -chdir={{tfDir}} fmt
    terraform -chdir={{tfDir}} init
    terraform -chdir={{tfDir}} validate

_terraform-clean:
    rm -rf {{tfDir}}/.terraform

# show terraform state
terraform-show *args: (_terraform-init) && (_terraform-clean)
    terraform -chdir={{tfDir}} show {{args}}

# plan terraform config
terraform-plan *args: (_terraform-init) && (_terraform-clean)
    terraform -chdir={{tfDir}} plan {{args}}

# apply terraform config
terraform-apply: (_terraform-init) && (_terraform-clean)
    terraform -chdir={{tfDir}} apply -auto-approve

# destroy terraform config
terraform-destroy *args: (_terraform-init) && (_terraform-clean)
    terraform -chdir={{tfDir}} destroy {{args}}

# refresh terraform state
terraform-refresh: (_terraform-init) && (_terraform-clean)
    terraform -chdir={{tfDir}} refresh

# show terraform outputs
terraform-outputs: (_terraform-init) && (_terraform-clean)
    terraform -chdir={{tfDir}} output