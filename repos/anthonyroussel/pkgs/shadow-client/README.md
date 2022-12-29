# Shadow on NixOS

The goal of this project is to provide Shadow on NixOS with a dynamic derivation to handle frequent updates.

This repository is a fork of the great work of [NicolasGuilloux](https://github.com/NicolasGuilloux) & [Elyhaka](https://github.com/Elyhaka) on the [Shadow on NixOS](https://github.com/NicolasGuilloux/shadow-nix) project. The purpose of this fork is to continue to maintain this project with the latest NixOS & Shadow versions.

**:warning: This project is not affiliated with Blade, the company providing Shadow, in any way.**

![Shadow loves Nix](./assets/images/shadow_loves_nix.svg)

## Table of content

1. [Installation](#1-installation)
  - [As a system package](#as-a-system-package)
  - [As a home-manager package](#as-a-home-manager-package)
2. [Configuration](#2-configuration)
  - [Package configuration](#package-configuration)
  - [XSession configuration](#xsession-configuration)
  - [Systemd session configuration](#systemd-session-configuration)
3. [About VAAPI](#3-about-vaapi)
  - [An example for Intel and AMD GPU](#an-example-for-intel-and-amd-gpu)
4. [Versioning](#4-versioning)
5. [Contributing](#5-contributing)
6. [License](#6-license)
7. [Mentions](#7-mentions)

## 1. Installation

Note that the ref value (`v*.*.*`) should point to the lastest release. Checkout the tags to know it. The version is the derivation one, not the launcher nor the streamer version. Installing any version of this repository will always install the latest version of the launcher available.

If you want the latest package derivation, use `ref = "main"` instead.

#### As a system package

In your `configuration.nix` :

```nix
{
  imports = [
    (fetchGit { url = "https://github.com/anthonyroussel/shadow-nix"; ref = "refs/tags/v1.3.2"; } + "/import/system.nix")
  ];

  programs.shadow-client = {
    # Enabled by default when using import
    # enable = true;
    channel = "prod";
  };
}
```

#### As a home-manager package

In your `home.nix` :

```nix
{
  imports = [
    (fetchGit { url = "https://github.com/anthonyroussel/shadow-nix"; ref = "refs/tags/v1.3.2"; } + "/import/home-manager.nix")
  ];

  programs.shadow-client = {
    # Enabled by default when using import
    # enable = true;
    channel = "preprod";
  };
}
```

## 2. Configuration

#### Package configuration

This is the configuration of the package itself. You can set them via `programs.shadow-client.<key>`.

| Key                   | Type   | Default | Possible values                | Description                                               |
|-----------------------|--------|---------|--------------------------------|-----------------------------------------------------------|
| enable                | bool   | false   | true, false                    | Enable the package                                        |
| channel               | enum   | prod    | prod, preprod, testing         | `prod` is stable, `preprod` is beta, `testing` is alpha   |
| extraChannels         | [enum] | []      | [ "prod" "preprod" "testing" ] | `prod` is stable, `preprod` is beta, `testing` is alpha   |
| launchArgs            | string |         |                                | Add launch arguments to the renderer                      |
| enableDesktopLauncher | bool   | true    | true, false                    | Creates a .desktop entry                                  |
| enableDiagnostics     | bool   | false   | true, false                    | Provide debug tools                                       |
| forceDriver           | enum   | null    | iHD, i965, radeon, radeonsi    | Force the LIBVA driver                                    |
| enableGpuFix          | bool   | true    | true, false                    | Create the `drirc` file to fix some driver related issues |


#### XSession configuration

This package also provides a standalone session with only the necessary component to start Openbox and Shadow. You can set the configuration via `programs.shadow-client.x-session.<key>`.

| Key                   | Type   | Default | Possible values             | Description                                                |
|-----------------------|--------|---------|-----------------------------|------------------------------------------------------------|
| enable                | bool   | false   | true, false                 | Enable the standalone XSession                             |
| additionalMenuEntries |        | {}      |                             | Additional menu entries for the Openbox right click menu   |
| startScript           | string |         |                             | Additional start option to be executed when Openbox starts |


#### Systemd session configuration

This package provides a standalone systemd daemon to start only the client wrapped into Xorg in a TTY. You can set the configuration at `programs.shadow-client.systemd-session.<key>`.

| Key          | Type   | Default | Possible values             | Description                                  |
|--------------|--------|---------|-----------------------------|----------------------------------------------|
| enable       | bool   | false   | true, false                 | Enable the standalone XSession with Systemd  |
| user         | string |         |                             | User that will start the session             |
| tty          | int    | 8       |                             | TTY number where the session will be started |
| onClosingTty | int    | null    |                             | TTY number that will be selected on closing  |


## 3. About VAAPI

It is important to have `vaapi` enabled to make Shadow works correctly. You can find information on this [NixOS wiki page](https://nixos.wiki/wiki/Accelerated_Video_Playback).


#### An example for Intel and AMD GPU

The following example should work for both AMD and Intel GPU. This is just an example, there is no guarantee that it will work.

```nix
{
  # Provides the `vainfo` command
  environment.systemPackages = with pkgs; [ libva-utils ];

  # Hardware hybrid decoding
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # Hardware drivers
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };
}
```

## 4. Versioning

`shadow-nix` follows [semantic versioning](https://semver.org/). In short the scheme is MAJOR.MINOR.PATCH where
1. MAJOR is bumped when there is a breaking change,
2. MINOR is bumped when a new feature is added in a backward-compatible way,
3. PATCH is bumped when a bug is fixed in a backward-compatible way.

Versions below 1.0.0 are considered experimental and breaking changes may occur at any time.

## 5. Contributing

Contributions are welcomed! There are many ways to contribute, and we appreciate all of them. Here are some of the major ones:

* [Bug Reports](https://github.com/anthonyroussel/shadow-nix/issues): While we strive for quality software, bugs can happen and we can't fix issues we're not aware of. So please report even if you're not sure about it or just want to ask a question. If anything the issue might indicate that the documentation can still be improved!
* [Feature Request](https://github.com/anthonyroussel/shadow-nix/issues): You have a use case not covered by the current api? Want to suggest a change or add something? We'd be glad to read about it and start a discussion to try to find the best possible solution.
* [Pull Request](https://github.com/anthonyroussel/shadow-nix/merge_requests): Want to contribute code or documentation? We'd love that! If you need help to get started, GitHub as [documentation](https://help.github.com/articles/about-pull-requests/) on pull requests. We use the ["fork and pull model"](https://help.github.com/articles/about-collaborative-development-models/) were contributors push changes to their personnal fork and then create pull requests to the main repository. Please make your pull requests against the `main` branch.

As a reminder, all contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## 6. License

`shadow-nix` is distributed under the terms of the [Unlicense license](LICENSE).

## 7. Mentions

This repository was originally created and maintained by [Elyhaka](https://github.com/Elyhaka) and [NicolasGuilloux](https://github.com/NicolasGuilloux). A big thanks to them for helping me learning Nix!

## ✨ Contributors

<a href="https://github.com/anthonyroussel/shadow-nix/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=anthonyroussel/shadow-nix" />
</a>

Made with [contrib.rocks](https://contrib.rocks).
