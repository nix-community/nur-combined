# nur
My personal NUR packages.
## How to use
You have to [include the NUR](https://github.com/nix-community/NUR?tab=readme-ov-file#installation) in your configuration.

My NUR namespace is `nur.repos.someron`.


## Packages
### External
#### riscVivid
- Source: https://github.com/unia-sik/riscVivid
- Description: A RISC-V processor simulator
- Current Version: 1.4 *(2022-07-12)*
- License: GPL 3.0 (or later)
- Attribute: `nur.repos.someron.pkgs.riscVivid`

#### filebrowser-quantum
- Source: https://github.com/gtsteffaniak/filebrowser
- Description: 📂 Web File Browser
- Current Version: v1.1.2-stable *(2026-02-07)*
- License: Apache License 2.0
- Attribute: `nur.repos.someron.pkgs.filebrowser-quantum`

### Own packages
#### systemd-sops-creds
- Source: https://codeberg.org/someron/systemd-sops-creds
- Description: Use your SOPS files as systemd credentials.
- Current Version: v1.0.0 *(2026-01-28)*
- License: MIT
- Attribute: `nur.repos.someron.pkgs.systemd-sops-creds`

#### beszel-provisioner
- Source: https://codeberg.org/someron/beszel-provisioner
- Description: Declaratively configure users, systems, alerts and OAuth2 for beszel!
- Current Version: 2025-09-29
- License: MIT
- Attribute: `nur.repos.someron.pkgs.beszel-provisioner`

#### carddav-immich-bday-sync
- Source: [in this repo](pkgs/carddav-immich-bday-sync/src/)
- Description: Sync the birthdays of your contacts on a CardDAV server to your Immich instance.
- License: MIT
- Attribute: `nur.repos.someron.pkgs.carddav-immich-bday-sync`
