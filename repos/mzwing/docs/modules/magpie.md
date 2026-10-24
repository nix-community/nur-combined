# magpie modules

These NixOS and nix-darwin modules run the gateway of [magpie](https://github.com/yetone/magpie) (`magpie serve`) as the user whose agents use it, and merge declared keys into magpie's own `settings.json`. Everything else magpie keeps, such as providers, accounts and routing groups, stays magpie's state.

## Usage

```nix
# configuration.nix
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nur.repos.mzwing.modules.nixos.magpie
  ];

  services.magpie = {
    enable = true;
    package = pkgs.nur.repos.xyenon.magpie;
    user = "alice";
    settings.bareModelIDs = true;
  };
}
```

On nix-darwin, import `inputs.nur.repos.mzwing.modules.darwin.magpie`; it has no `user`, and `package` may stay null. When consuming this repository directly as a flake input, import `inputs.mzwing.nixosModules.magpie` or `inputs.mzwing.darwinModules.magpie` instead.

The gateway listens on `host` and `port`, which reach magpie as `MAGPIE_ADDR`, so turning on sharing in magpie keeps it there. Anything else goes through `env`, such as `MAGPIE_PUBLIC_URL` behind a reverse proxy.

`web.enable` also serves the page of `magpie web`, the app's window in a browser, from the same process on `web.host` and `web.port`. The page asks for a key, which the link in the log carries. magpie makes a new key at every start unless `MAGPIE_WEB_KEY` sets one, which browsers then stay signed in with. Anyone holding it can change magpie and read its keys, so keep it out of `env`, which is stored in the Nix store; on NixOS, set it from a file with `systemd.services.magpie.serviceConfig.EnvironmentFile`.

Before every start, `settings` is merged into `settings.json` in `$XDG_CONFIG_HOME/magpie`, else `~/.config/magpie`. Its keys are the JSON names of `Settings` in magpie's `internal/settings/settings.go`. The keys merged are recorded in `.magpie-nix-managed.json` beside it, so a key dropped from `settings` is dropped from the file as well, while keys set in magpie itself stay. The file as it was before the first merge is kept as `settings.json.stateful`. A `settings.json` that does not parse stops the start instead of being replaced.

## NixOS

The service runs as `user`, so magpie keeps its state in that user's home and finds the agents' sign-ins there. `package` is installed system-wide for the CLI too.

```console
$ systemctl restart magpie
$ journalctl -u magpie -f
```

## nix-darwin

The gateway runs as a LaunchAgent in the session of whoever logs in, where magpie can reach the agents' sign-ins, the login keychain's included. With `package` left null it runs `/Applications/magpie.app`, as the `magpie-app` Homebrew cask installs it. Turn off the app's own launch at login with `magpie autostart off`: two magpies started at login take turns failing on the port. The app opened by hand uses the agent's gateway.

Set `logFile` to keep the gateway's output:

```console
$ launchctl kickstart -k gui/$UID/org.nixos.magpie
$ tail -f ~/Library/Logs/magpie.log
```
