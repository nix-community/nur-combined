# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

CI code from [cryolitia](https://github.com/nix-community/nur-combined/tree/dca43584b1cbd8cab9be013d74e71cd1be16e953/repos/cryolitia).

![Build and populate cache](https://github.com/dev380/nur-repo/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-dev380-blue.svg)](https://dev380.cachix.org)

## Packages

| attribute | description |
| --- | --- |
| `dfmic` | DeepFilterNet3_ll noise suppression as a PipeWire virtual microphone, on the Intel NPU |
| `redlib` | private front-end for Reddit |
| `rbonsai` | `cbonsai` in Rust |
| `wisdom-tree` | TUI concentration app: pomodoro, music, Lo-fi radio |
| `ez` | CLI for the e-z.host API |
| `nohang` | low-memory handler for Linux |
| `noto-fonts-emoji-blob-bin` | Blobmoji emoji font |
| `clockface-font` | clockface icon font |

## dfmic

A virtual microphone that removes background noise with DeepFilterNet3_ll, running
the three converted graphs on the Intel NPU (Intel AI Boost) instead of the CPU.
It is a PipeWire `Audio/Source` named `dfmic-source`; the CLI and a Slint window
control it over the session D-Bus.

Upstream: <https://github.com/Dev380/dfmic>

### Package

```nix
nur.repos.dev380.dfmic
```

The package carries **no model**; it is downloaded on request. See `models`
below for the offline alternative.

```sh
nix build nur.repos.dev380.dfmic
# or, from a checkout of this repository:
nix build .#dfmic
```

The build runs the crate's tests, GUI ones included.

### Running it as a service

This repository ships the package, not a NixOS module: the service is a *user*
unit, and which user, which microphone and whether to take over the default are
all machine-local decisions. A minimal home-manager service:

```nix
systemd.user.services.dfmic = {
  Unit = {
    After = ["pipewire.service" "wireplumber.service"];
    PartOf = ["pipewire.service"];
  };
  Service = {
    ExecStart = "${pkgs.nur.repos.dev380.dfmic}/bin/dfmic run --device NPU";
    # The daemon forks these: `pw-metadata` to restore the default source after
    # an unclean stop, and curl/tar/gzip for the model download.
    Environment = ["PATH=${lib.makeBinPath (with pkgs; [pipewire curl coreutils gnutar gzip])}"];
    Restart = "on-failure";
    RestartSec = 3;
  };
  Install.WantedBy = ["default.target"];
};
```

Realtime scheduling needs two things, both of which bite if you skip them:

```nix
security.rtkit.enable = true;                 # system-wide
Service.LimitRTTIME = 200000;                 # on the unit
```

`LimitRTTIME` is what rtkit checks before granting a request — it refuses a
caller whose budget exceeds its own 200 ms maximum. `LimitRTPRIO` will not work
in its place: a user unit's value is accepted by systemd and silently ignored,
because the user manager itself runs at 0. Without either the daemon says so once
and filters at normal priority, which still works.

### The model: download or bundle

The converted graphs are ~18 MB of OpenVINO IR. They are *not* in the closure by
default:

```sh
dfmic models download        # into $XDG_DATA_HOME/dfmic/models/DeepFilterNet3_ll-0.5.6/
```

or press **Download the model (20 MB)** in the window. The archive is verified
against a SHA-256 built into the binary before it is unpacked, and it is unpacked
beside its destination and moved into place, so an interrupted download never
leaves a half-model that later looks usable. Until then the daemon runs and
passes the raw microphone through, unfiltered.

For a machine that is never online, put the same graphs in the closure:

```nix
let
  dfmic = nur.repos.dev380.dfmic.override { withModels = true; };
in {
  # `modelsPath` is where the IR sits in this variant, so nothing has to know the
  # store layout. It is `null` for the download variant, which is how a unit can
  # tell the difference instead of pointing at a path that does not exist.
  systemd.user.services.dfmic.serviceConfig.ExecStart =
    "${dfmic}/bin/dfmic run --device NPU --models ${dfmic.modelsPath}";
}
```

### Verifying it works

```sh
dfmic doctor                 # lists OpenVINO devices, times a second of audio
dfmic status                 # state, source, latency, overruns
dfmic on                     # start filtering
dfmic enhance in.wav out.wav --agc    # the same engine, offline
```

`dfmic status` reports `state: no-model` until the graphs are present,
`no-device` when the capture node is gone — it reconnects on its own rather than
exiting — and `filtering` once an application is recording from it.
