{ config, lib, ... }:

let
  inherit (lib) escapeShellArg mapAttrs' nameValuePair;
in
{
  # Pending https://github.com/NixOS/nixpkgs/issues/163080
  system.activationScripts = mapAttrs'
    (name: user: nameValuePair "accounts-service-icon-${name}" {
      text = ''
        face="$(getent passwd ${escapeShellArg user.name} | cut -d: -f6)/.face"

        if [[ -f "$face" ]]; then
          cp --reflink=auto --update --verbose "$face" '/var/lib/AccountsService/icons/'${escapeShellArg user.name}
        fi
      '';
    })
    config.users.users;
}
