# Suwayomi-Server {#module-services-suwayomi-server}

A free and open source manga reader server that runs extensions built for Tachiyomi.

## Basic usage {#module-services-suwayomi-server-basic-usage}

By default, the module will execute Suwayomi-Server backend and serve the web UI:

```nix
{ ... }:

{
  services.suwayomi-server = {
    enable = true;
  };
}
```

It runs in the systemd service named `suwayomi-server` in the data directory `/var/lib/suwayomi-server`.

You can change the default parameters with some other parameters:
```nix
{ ... }:

{
  services.suwayomi-server = {
    enable = true;

    dataDir = "/var/lib/suwayomi"; # Default is "/var/lib/suwayomi-server"
    openFirewall = true;

    settings = {
      server.port = 4567;
    };
  };
}
```

If you want to create a desktop icon, you can activate the system tray option:

```nix
{ ... }:

{
  services.suwayomi-server = {
    enable = true;

    dataDir = "/var/lib/suwayomi"; # Default is "/var/lib/suwayomi-server"
    openFirewall = true;

    settings = {
      server.port = 4567;
      server.systemTrayEnabled = true;
    };
  };
}
```

The module always starts Suwayomi-Server with
`-Dsuwayomi.tachidesk.config.server.rootDir=${dataDir}`,
so the app stores its files (including `server.conf`) directly in
`services.suwayomi-server.dataDir`.
Previously, Suwayomi-Server would store its files under `${dataDir}/.local/share/Tachidesk`.
To migrate, move the contents of `${dataDir}/.local/share/Tachidesk` into `${dataDir}`.

The `server.conf` itself is Nix-managed: on each start the module copies the
generated config to `${dataDir}/server.conf` as a writable file (the server
rewrites it on startup, so a symlink into `/nix/store` does not work).
A stale symlink left at `${dataDir}/.local/share/Tachidesk/server.conf` is
removed automatically.

## Basic authentication {#module-services-suwayomi-server-basic-auth}

You can configure authentication for the web interface with:

```nix
{ ... }:

{
  services.suwayomi-server = {
    enable = true;

    openFirewall = true;

    settings = {
      server.port = 4567;
      server = {
        authMode = "basic_auth";
        authUsername = "username";

        # NOTE: this option is a NixOS option only
        # and doesn't exist in the upstream configuration
        authPasswordFile = "/run/secrets/your-secret-password-file";
      };
    };
  };
}
```

## Extra configuration {#module-services-suwayomi-server-extra-config}

Not all the configuration options are available directly in this module, but you can add the other options of suwayomi-server with:

```nix
{ ... }:

{
  services.suwayomi-server = {
    enable = true;

    openFirewall = true;

    settings = {
      server = {
        port = 4567;
        autoDownloadNewChapters = false;
        maxSourcesInParallel = 6;
        extensionRepos = [
          "https://raw.githubusercontent.com/MY_ACCOUNT/MY_REPO/repo/index.min.json"
        ];
      };
    };
  };
}
```

<!--
  NOTE: this chapter must define exactly the anchor IDs listed for
  suwayomi-server in nixpkgs' nixos/doc/manual/redirects.json
  (module-services-suwayomi-server, -basic-usage, -basic-auth,
  -extra-config) — no more, no fewer — otherwise the manual build
  (documentation.nixos.checkRedirects) fails with RedirectsError.
  Do not add anchored sections here.
-->
