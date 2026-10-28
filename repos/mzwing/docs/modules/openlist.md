# openlist module

This NixOS module runs [OpenList](https://github.com/OpenListTeam/OpenList) (`OpenList server`) from nixpkgs' `openlist` package, as its own system user.

## Usage

```nix
# configuration.nix
{inputs, ...}: {
  imports = [
    inputs.nur.repos.mzwing.modules.nixos.openlist
  ];

  services.openlist = {
    enable = true;
    env = {
      OPENLIST_SITE_URL = "https://files.example.com";
      OPENLIST_ADDR = "127.0.0.1";
    };
  };
}
```

When consuming this repository directly as a flake input, import `inputs.mzwing.nixosModules.openlist` instead.

OpenList keeps `config.json`, its database and temporary files in `dataDir`, and rewrites `config.json` at every start. Any key of `config.json` can be set through `env` with the `OPENLIST_` prefix, such as `OPENLIST_SITE_URL` for `site_url` or `OPENLIST_HTTP_PORT` for `scheme.http_port`; the names are the `env` tags in OpenList's `internal/conf/config.go`. `env` is stored in the Nix store, so keep secrets out of it and set them from a file with `systemd.services.openlist.serviceConfig.EnvironmentFile`.

The first start prints the admin user's password to the journal. To set your own:

```console
$ sudo -u openlist OpenList admin set <password> --data /var/lib/openlist
```
