# whs's nix flakes
This repository contains various flake that I use

## Usage

### NUR
This repository is available in [NUR](https://nur.nix-community.org/documentation/#installation) as `nur.repos.whs`

### As Nix Flake
First, enable nix flakes if you haven't:

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Then in your flake, add this repository

```nix
{
	inputs = {
		whs.url = "github:whs/nix";
	};
}
```

## Packages
### readsb
[Readsb is a Mode-S/ADSB/TIS decoder for RTLSDR, BladeRF, Modes-Beast and GNS5894 devices](https://github.com/wiedehopf/readsb)

Available as standalone package or as NixOS module.

Tested to build and start on Linux x86_64 or cross compiled to Raspberry Pi 1B/B+ (armv6hf)

#### Package options

* useHistory: Build with history support (default: true)
* useRtlsdr: Build with RTL-SDR support (default: true)
* usePlutosdr: Build with PlutoSDR support (default: true)
* useSoapysdr: Build with SoapySDR support (default: true)
* useBiastee: Build with Bias Tee support (default: true)
* useHackrf: Build with HackRF support (default: true)

#### NixOS options

* services.readsb.enable: Whether readsb is enabled. This also automatically configure your system for RTL-SDR (default: false)
* services.readsb.package: Which readsb package to use
* services.readsb.options: Command line argument to readsb as a set (default: same as upstream Debian default options)
* services.readsb.openFirewallOutput: Whether output firewall ports (30002, 30003, 30005) should be opened (default: true)
* services.readsb.openFirewallInput: Whether input firewall ports (30001, 30004, 30104) should be opened (default: false)

### crisp-status-local
[Monitor internal hosts and report their status to Crisp Status](https://github.com/crisp-im/crisp-status-local)

Available as standalone package or as NixOS module.

#### NixOS options

* services.crisp-status-local.enable: Whether crisp-status-local is enabled (default: false)
* services.crisp-status-local.package: Which crisp-status-local package to use
* services.crisp-status-local.token: Crisp status token (currently this would leak secret to Nix cache)
* services.crisp-status-local.config: [crisp-status-local configuration](https://github.com/crisp-im/crisp-status-local#configuration) as set

### google-ops-agent
[Ops Agent is the primary agent for collecting telemetry from your Compute Engine instances](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/)

This is work in progress

## License
[The MIT License](LICENSE)
