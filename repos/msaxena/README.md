# nurpkgs

My personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- `scrobblex` — self-hosted Plex-to-Trakt scrobbler.
- `trek` — self-hosted, collaborative travel planner ([liketrek/TREK](https://github.com/liketrek/TREK)).
- `yamtrack` — self-hosted media tracker (movies, TV, anime, manga, games, books, ...).
  Built from source against nixpkgs' Python packages; does not include the
  upstream Docker image's nginx/supervisord layer. Use `nixosModules.yamtrack`
  to run it.

## NixOS modules

- `nixosModules.scrobblex` — runs scrobblex as a systemd service.
- `nixosModules.trek` — runs TREK as a systemd service.
- `nixosModules.yamtrack` — runs Yamtrack's web server, migrations and
  Celery worker/beat as systemd services.

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

Exposes the app's full configuration surface as typed options; see
`nixos-modules/yamtrack.nix` for the complete list (providers, database,
redis, OAuth/social login, etc). Credential-shaped settings (the Django
secret key, provider API keys, a remote database password, ...) are
deliberately not plain Nix options — they go through `environmentFiles`, a
list of `KEY=value` files loaded by systemd (`EnvironmentFile=`), so nothing
sensitive ends up in the Nix store. That option's description lists every
supported key.

```nix
{
  imports = [ inputs.nur.repos.msaxena.modules.nixos.yamtrack ];

  services.yamtrack = {
    enable = true;
    urls = [ "https://yamtrack.example.com" ];
    database.createLocally = true; # local Postgres, peer-authenticated, no password
    environmentFiles = [ config.sops.secrets."yamtrack-env".path ];
  };
}
```

State: with the sqlite default, only `/var/lib/yamtrack` needs to survive a
reboot (add it to your impermanence persistence list); with
`database.createLocally`, persist `/var/lib/postgresql` instead. Redis holds
only cache/broker data and needs no persistence either way.
