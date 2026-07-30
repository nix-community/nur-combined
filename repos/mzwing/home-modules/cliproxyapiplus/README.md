# CLIProxyAPI Plus Home Manager module

Import the module from the flake and enable its user service:

```nix
{
  config,
  inputs,
  ...
}: {
  imports = [inputs.nur-packages.homeModules.cliproxyapiplus];

  services.cliproxyapiplus = {
    enable = true;

    # This must be an external runtime secret, not a Nix store path. The file
    # contains a YAML or JSON sequence of non-empty strings.
    apiKeysFile = config.sops.secrets.cliproxyapiplus-api-keys.path;

    managedSettings = {
      host = "localhost";
      port = 8317;
      tls = {
        enable = false;
        cert = "";
        key = "";
      };
      remote-management = {
        allow-remote = false;
        disable-control-panel = false;
        panel-github-repository = "https://github.com/router-for-me/Cli-Proxy-API-Management-Center";
      };
      auth-dir = "${config.home.homeDirectory}/.cli-proxy-api";
      debug = false;
      commercial-mode = false;
      logging-to-file = false;
      logs-max-total-size-mb = 10;
      usage-statistics-enabled = false;
      proxy-url = "";
      force-model-prefix = false;
      request-retry = 3;
      max-retry-interval = 30;
      disable-image-generation = false;
      quota-exceeded = {
        switch-project = true;
        switch-preview-model = true;
        antigravity-credits = false;
      };
      routing = {
        strategy = "round-robin";
        session-affinity = false;
        session-affinity-ttl = "1h";
      };
      ws-auth = false;
      nonstream-keepalive-interval = 0;
      codex-instructions-enabled = true;
      streaming = {
        keepalive-seconds = 15;
        bootstrap-retries = 1;
      };
      redis-usage-queue-retention-seconds = 60;
    };
  };
}
```

The API key secret file has this shape:

```yaml
- sk-example-first
- sk-example-second
```

`managedSettings` is written to the Nix store, so it must contain no secrets;
the module only accepts the stable keys shown above and rejects provider/model
sections. In particular, `proxy-url` must not contain URL userinfo. At service
start, the module recursively overlays those settings onto the writable runtime
file at `~/.config/cliproxyapiplus/config.yaml`, then overlays `apiKeysFile` as
the top-level `api-keys`. Provider credentials, model lists, management state,
and plugins that are not declared in `managedSettings` remain in the runtime
file and survive restarts. Changes to a field declared in `managedSettings` are
intentionally reset to its declarative value on restart.

The runtime configuration must be a regular writable file, not a Home Manager
store symlink. Before enabling the service for the first time, migrate an
existing configuration manually:

```console
$ mkdir -p ~/.config/cliproxyapiplus
$ cp /path/to/current/config.yaml ~/.config/cliproxyapiplus/config.yaml
$ chmod 600 ~/.config/cliproxyapiplus/config.yaml
```

An optional external `environmentFile` can provide literal `KEY=VALUE` entries
such as `MANAGEMENT_PASSWORD`. Variable names must be shell identifiers; values
are not evaluated and quotes are not removed. Blank lines and `#` comment lines
are ignored. Only the file path is stored in the generated service. The runtime
configuration and both secret-file options must point outside `/nix/store`.
Restart the service after rotating `apiKeysFile`:

```console
$ systemctl --user restart cliproxyapiplus.service
```

On macOS:

```console
$ launchctl kickstart -k gui/$(id -u)/org.nix-community.home.cliproxyapiplus
```
