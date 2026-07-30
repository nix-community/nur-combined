# nurpkgs

My personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- `scrobblex` — self-hosted Plex-to-Trakt scrobbler.
- `trek` — self-hosted, collaborative travel planner ([liketrek/TREK](https://github.com/liketrek/TREK)).

## NixOS modules

- `nixosModules.scrobblex` — runs scrobblex as a systemd service.
- `nixosModules.trek` — runs TREK as a systemd service.

```nix
{
  imports = [ inputs.nur.repos.msaxena.modules.nixos.scrobblex ];

  services.scrobblex = {
    enable = true;
    environmentFile = "/run/secrets/scrobblex";
  };
}
```

```nix
{
  imports = [ inputs.nur.repos.msaxena.modules.nixos.trek ];

  services.trek = {
    enable = true;
    allowedOrigins = [ "https://trek.example.com" ];
    environmentFiles = [ "/run/secrets/trek-env" ]; # ENCRYPTION_KEY, etc.
  };
}
```

`services.trek` covers most of upstream's `.env.example` as typed options
(session/cookie settings, OIDC, MCP, Overpass, ...); anything not covered
can be set via `services.trek.environment` (non-secret) or
`services.trek.environmentFiles` (secret). Two things worth calling out:

- **impermanence**: state lives entirely under `services.trek.dataDir`
  (`/var/lib/trek` by default), fully managed by systemd's
  `StateDirectory=`. Add that one path to your persistence config and
  nothing else needs to change — the persistent bind mount is already in
  place before the service starts.
- **sops-nix**: `environmentFiles` takes a list of paths, so
  `[ config.sops.secrets.trek-env.path ]` (a templated sops-nix secret
  combining `ENCRYPTION_KEY`, `OIDC_CLIENT_SECRET`, etc.) or one path per
  sops secret both work directly.
