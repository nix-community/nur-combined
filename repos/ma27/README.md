# nur-packages

[![pipeline status](https://gitlab.com/Ma27/nur-packages/badges/master/pipeline.svg)](https://gitlab.com/Ma27/nur-packages/commits/master)

My own user-contributed packages as proposed in [nix-community/NUR](https://github.com/nix-community/nur).

## Setup

Add `NUR` as [described in the docs](https://github.com/nix-community/nur#how-to-use):

``` nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

## Packages

* `gianas-return` (`pkgs.nur.repos.ma27.gianas-return`): Giana’s Return aims to be a worthy
  UNOFFICIAL sequel of 'The Great Giana Sisters'.

## Overlays

There are several overlays available that can be imported with an expression like this:

```
{ pkgs, config, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    pkgs = import <nixpkgs> {}; # create dummy pkgs to load modules (that require `pkgs.lib` for evaluation)
  };
in
  {
    nixpkgs.overlays = [
      nur-no-pkgs.repos.ma27.overlays.<overlay-name>
    ];
  }
```

The following overlays are available:

* `overlays.sudo`: Provides a patched `sudo` with the `--with-insults` flag enabled.
* `overlays.termite`: Provides a patched `termite` with the patch
  from `[thestinger/termite#621](https://github.com/thestinger/termite/pull/621)` which allows to
  use `termite` without the `F11` hotkey enabled. This is e.g. helpful when using `weechat` in `termite`.
* `overlays.sqldeveloper`: Patched `sqldeveloper` with `oraclejdk` and at version `18.2.0.183.1748`. The
  original patch is [on-hold at `nixpkgs`](https://github.com/NixOS/nixpkgs/pull/44624).

## Modules

### Initial setup

Unfortunately it's currently impossible to load modules that are defined as list in the `pkgs`
can't be imported using `imports = []`. This occurrs due to the evaluation order in the module system,
the config will be merged (including `imports`), after that the evaluation starts.

The package set is imported by default in `nixpkgs.pkgs`. Therefore we have to work around by evaluating `NUR`
in a second package set:

``` nix
{ pkgs, config, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    pkgs = import <nixpkgs> {}; # create dummy pkgs to load modules (that require `pkgs.lib` for evaluation)
  };
in
{
  imports = [
    nur-no-pkgs.repos.ma27.modules.hydra
    nur-no-pkgs.repos.ma27.modules.weechat
  ];
}
```

### Hydra setup

The [Hydra CI](https://nixos.org/hydra/) is a build system for Nix.

The module provides a patch to [disable restricted eval](https://github.com/NixOS/hydra/issues/531) and some additional configuration
such as a notifier, a basic VHost with [ACME](https://letsencrypt.org/docs/client-options/) support.

It can be easily configured like this:

``` nix
{
  ma27.hydra = {
    enable = true;
    architectures = [ "x86_64-linux" ];       # which architectures shall be supported
    vhost = "hydra.example.org";              # VHost to listen on
    email = "random@email.org";               # admin email (e.g. for ACME cert)
    initialPassword = "randompwd";            # initial password for the admin account
    keyDir = "hydra.random.org";              # keydir for the build artifacts (also used for the binary cache name), lives in `/etc/nix/${keyDir}`
    extraConfig = {                           # basic extra config for `services.hydra` from nixpkgs
      # …
    };
  };
}
```

**Limitations**:

* Only allows local build machines.
* Fairly opinionated, lacks several features.

For private repositories a private key has to be generated to allow
Hydra to clone them:

```
sudo -u hydra -i
ssh-keygen
```

### Weechat

The [Weechat](https://weechat.org/) module allows to configure declaratively a Weechat instance in your user profile (namely `$HOME/.cache`)
and allows to run it locally or using a `screen` session managed by `systemctl --user`.

It can be easily configured like this:

``` nix
{
  ma27.weechat = {
    enable = true;
    useInScreen = true;       # add screen service
    sec = ./sec.conf;         # `types.path` to `sec.conf`
    irc = ./irc.conf;         # `types.path` to `irc.conf`
    plugins = ./plugins.conf  # `types.path` to `plugins.conf`
  };
}
```

Additionally it's fairly easy to reload the `screen` session after changing the config:

```
systemctl --user daemon-reload
systemctl --user restart weechat-screen.service
```

The session can be accessed with `screen -r weechat`.

## Additional library

The library contains simple helper functions to provision and deploy [Hetzner Cloud](https://www.hetzner.com/cloud).
The main function is `mkHetznerVM`:

``` nix
let

  nur-no-pkgs = load nur; # see above

in
{
  machine1 = { pkgs, ... }: with nur-no-pkgs.repos.ma27.lib; mkHetznerVM {
    name = "name-of-the-vm";
    hostName = "actual hostname";
    ipv4 = "0.0.0.0";               # static IPv4 assigned by hetzner cloud
    ipv6 = "::1";                   # static IPv6 assigned by hetzner cloud

    users.extraUsers.test = {       # add some users
      # …
    };

    imports = [
      # import some modules
    ];

    boot = {
      loader.grub = mkGrub "/dev/sda"; # harddrive with the bootloader
      initrd = mkInitrd {
        "any-device" = {
          device = "/dev/path/to/device";
          allowDiscards = true;
          # additional hardware config
        };
      };
    };

    rootPart = "/dev/disk/to/root";
    swapPart = "any-uuid";              # /dev/disk/by-uuid/${swapPart}
    bootPart = "any-uuid";              # /dev/disk/by-uuid/${bootPart}
  };
}
```

Additionally `lib/default.nix` provides two more functions, `mkGrub` and `mkInitrd`:

* `mkGrub x`: returns the basoc configuration for the `loader.grub` submodule
  with a given device `x`.

* `mkInitrd x`: creates a wrapper for an [`initrd`](https://wiki.debian.org/Initrd) configuration
  customized for a simple Hetzner cloud instance. It provides the needed kernel modules and
  sets the devices `x` accordingly assuming that `luks` will be used.

**Note:** please keep in mind that these functions are fairly customized for Hetzner cloud which
I use for most of my private systems. It requires careful testing especially when using it for
different systems!
