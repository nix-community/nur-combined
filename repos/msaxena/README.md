# nurpkgs

My personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- `scrobblex` — self-hosted Plex-to-Trakt scrobbler.

## NixOS modules

- `nixosModules.scrobblex` — runs scrobblex as a systemd service.

```nix
{
  imports = [ inputs.nur.repos.msaxena.modules.nixos.scrobblex ];

  services.scrobblex = {
    enable = true;
    environmentFile = "/run/secrets/scrobblex";
  };
}
```
