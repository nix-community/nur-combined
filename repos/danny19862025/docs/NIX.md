# Spotlight on Nix and NixOS

With flakes enabled, run Spotlight without installing it:

```sh
nix run github:danny19862025/spotlight
```

Or install it into your user profile:

```sh
nix profile install github:danny19862025/spotlight
spotlight
```

The flake supports x86_64-linux and aarch64-linux. It pins Nixpkgs to an
immutable revision in flake.nix and verifies vendored Cargo dependencies with
the flake's cargoHash. Update that hash when Cargo.lock changes. GTK runtime
schemas, Python, curl, ripgrep, and xdg-utils are supplied by its wrapper.

For declarative NixOS configurations, add this input:

```nix
inputs.spotlight.url = "github:danny19862025/spotlight";
```

Pass inputs to your module, then install:

```nix
environment.systemPackages = [ inputs.spotlight.packages.${pkgs.stdenv.hostPlatform.system}.default ];
```

Set your desktop keyboard shortcut to `spotlight`. The current
--install-shortcut command expects a user-local desktop entry, so use KDE
System Settings for a Nix installation. Login startup is opt-in with
`spotlight --autostart`; disable it with `spotlight --no-autostart`.

This package installs the core GTK launcher, icon, desktop entry, extension
catalog, and licenses. KDE integrations need the corresponding KDE services.
Optional Akonadi, free/busy, and paste-queue native helpers require separate
builds and their KDE/Qt dependencies. GNOME Calendar/Evolution integration
requires a separately configured Python GI and Evolution Data Server
environment; the packaged Python supplies core tools.

From a checkout, use:

```sh
nix flake check
nix build
nix develop
```

The fork contributor reports a successful x86_64-linux build on NixOS 26.11;
aarch64-linux is still unverified. Run these checks on your target system.
Desktop fixture tests remain opt-in.

Content-search exclusions are relative to each searched folder, so unit tests
can run under the Nix sandbox's /build without changing TMPDIR. The opener
fixture resolves `true` through PATH instead of requiring /bin/true. The pixbuf
loaders cache includes the separate WebP loader for checks and the launcher.
