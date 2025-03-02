{ config, lib, pkgs, ... }:

let
  inherit (lib) escapeShellArg getExe mapAttrs' nameValuePair;
  inherit (pkgs) crudini;
in
{
  # Pending https://github.com/NixOS/nixpkgs/issues/163080
  system.activationScripts = mapAttrs'
    (name: user: nameValuePair "accounts-service-icon-${name}"
    {
      text = ''
        face_path="$(getent passwd ${escapeShellArg user.name} | cut -d: -f6)/.face"
        icon_path='/var/lib/AccountsService/icons/'${escapeShellArg user.name}
        user_path='/var/lib/AccountsService/users/'${escapeShellArg user.name}

        if [[ -f "$face_path" ]]; then
          cp --reflink=auto --update --verbose "$face_path" "$icon_path"
          ${getExe crudini} --verbose --ini-options 'nospace' --set "$user_path" 'User' 'Icon' "$icon_path"
        fi
      '';
    })
    config.users.users;
}
