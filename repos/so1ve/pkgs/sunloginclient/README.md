# Sunlogin

Packages the official [Sunlogin Linux graphical client](https://sunlogin.oray.com/download/linux)
for `x86_64-linux` and `aarch64-linux`. Upstream calls the current application
`awesun`; this repository exposes it as `sunloginclient`.

## NixOS

The desktop client requires the system daemon. Import the module, enable the
service, and allow your desktop user to read its shared configuration:

```nix
{ inputs, ... }:
{
  imports = [ inputs.so1ve.nixosModules.sunloginclient ];

  nixpkgs.config.allowUnfree = true;
  services.sunloginclient.enable = true;
  users.users.your-user.extraGroups = [ "sunloginclient" ];
}
```

## UI scaling

Set the desktop interface scale independently of the system daemon:

```nix
services.sunloginclient.uiScale = 2; # 200%
```

Fractional scaling is not supported.
