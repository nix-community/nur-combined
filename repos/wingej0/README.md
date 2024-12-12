# wingej0's NUR Repository

**My personal [NUR](https://github.com/nix-community/NUR) repository**

## NordVPN

_Much of the work in this repository was done by [LuisChDev](https://github.com/LuisChDev/nur-packages) and a huge assist with declaring dependencies from my friend and fellow Qtile enthusiast, [Gurjaka](https://github.com/Gurjaka)_

To install NordVPN, you will need to import the NUR repository into your flake's inputs.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  ];
}
```

Then create a module for the NordVPN specific code.  I call mine nordvpn.nix, but it could also be in your configuration.nix.  The module uses an overlay to install the package and module.

```nix
{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.nur.modules.nixos.default
    inputs.nur.legacyPackages.x86_64-linux.repos.wingej0.modules.nordvpn
  ];

  # Install NordVPN
  nixpkgs.overlays = [
    (final: prev: {
      nordvpn = pkgs.nur.repos.wingej0.nordvpn;
    })
  ];

  # Enable the service
  services.nordvpn.enable = true;
}
```

Add nordvpn to the extraGroups option for your user.

```nix
users.users.${username} = {
  isNormalUser = true;
  description = "${username}";
  extraGroups = [ "nordvpn" ];
};
```

Finally, add the following to your network configuration to open the correct ports in the firewall.

```nix
{
  networking.wireguard.enable = true;

  # Open ports in the firewall.
  networking.firewall.checkReversePath = false;
  networking.firewall.allowedTCPPorts = [ 443 ];
  networking.firewall.allowedUDPPorts = [ 1194 ];
}
```

## Authenticating with the Daemon

Follow the instructions from the [Arch Wiki](https://wiki.archlinux.org/title/NordVPN) to login:

```bash
nordvpn login
```

Logs you in to your NordVPN Account.

>**Note:** Since April 2022, NordVPN uses web-based login, which does not return to terminal afterwards. To work around, copy the link after log in (right click on "continue" from your browser after login), which should start with "nordvpn://", and type the following in terminal (replace nordvpnlink with actual link, and keep the double quote):
>
>```bash
>nordvpn login --callback "nordvpnlink"
>
>```
>See comments from [nordvpn-bin AUR](https://aur.archlinux.org/packages/nordvpn-bin)
>
>Alternatively login via an access token generated from your account dashboard as below [NordVPN Dashboard](https://my.nordaccount.com/dashboard/nordvpn/)
>```bash
>nordvpn login --token "tokencode"
>```

```bash
nordvpn logout
```

Logs you out from your NordVPN Account.
