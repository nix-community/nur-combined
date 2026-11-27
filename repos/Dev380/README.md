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

Modules live in `modules/` (`nur.repos.dev380.modules.dfmic`) and are also
exported as `nixosModules.dfmic`.

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

### NixOS module

A user service — PipeWire, the session bus and the desktop are all per-user, and
`CAP_SYS_NICE` needs a system-wide capability wrapper.

```nix
{
  imports = [nur.repos.dev380.modules.dfmic]; # or nur.nixosModules.dfmic

  services.dfmic = {
    enable = true;
    package = nur.repos.dev380.dfmic;
    # source = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source";
  };
}
```

Enabling the module installs the daemon and its unit. Turning it on at login is
still a per-user choice: `dfmic autostart on`, or the switch in the window.

| option | default | meaning |
| --- | --- | --- |
| `package` | *(required)* | `nur.repos.dev380.dfmic` |
| `models` | `"download"` | `"download"` or `"bundled"` — see below |
| `device` | `"NPU"` | OpenVINO device; there is deliberately no CPU fallback |
| `source` | `null` | capture node name; `null` follows the system default |
| `takeDefault` | `true` | become the default source while filtering, then hand it back |
| `realtime` | `true` | grant `CAP_SYS_NICE` to the NPU worker (shorter worst case) |

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
services.dfmic = {
  enable = true;
  package = nur.repos.dev380.dfmic.override { withModels = true; };
  models = "bundled";
};
```

`models` reconciles `package`: asking for `"bundled"` with the default package
rebuilds it with the model, and `"download"` with a bundled package drops it. The
module then passes `--models` itself, so nothing has to know the store path.

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
