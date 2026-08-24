# Helios

Helios is the Moonlight OS streaming host. It pairs with Selene and other
Moonlight-compatible clients, exposes a local browser-based configuration
interface, and supports hardware encoding on AMD, Intel, and Nvidia GPUs.

## Moonlight OS features

- Stable per-client virtual displays and multi-display layouts
- Per-client launch, input, clipboard, and file permissions
- Authenticated QUIC transport negotiated per streaming session
- Session-scoped USB forwarding
- Read-only system-disk access for recovery workflows
- Microphone and camera uplinks
- Input-only sessions

All Moonlight OS extensions are negotiated. Clients that do not advertise an
extension continue through the compatible Moonlight protocol path.

## Getting started

See the [getting-started guide](docs/getting_started.md) for platform setup,
pairing, network ports, and troubleshooting. The extension designs live in:

- [Camera uplink](docs/moonlight-os-camera-uplink.md)
- [Display topology](docs/moonlight-os-display-topology.md)

Runtime settings are available from Helios's local web interface. The first
paired client receives administrative permissions; later clients begin with
view and app-list access until an administrator grants more.

Windows service installations can apply cryptographically signed releases from
the Home page. See [Updating Helios](docs/updating.md) for signature validation,
staging, health checks, and rollback behaviour.

## Virtual displays

Helios gives each paired client a stable display identity so its layout can be
restored on the next session. Windows uses SudoVDA. Linux uses the available
compositor or display-topology provider. If duplicate displays appear, remove
conflicting virtual-display drivers before troubleshooting Helios itself.

On dual-GPU systems, select the GPU that should encode the stream in the web
interface. Headless mode can render directly on a supported GPU without a
physical dummy plug.

## HDR

HDR availability depends on the host operating system, capture path, encoder,
client decoder, and display. Start with SDR when diagnosing colour or
brightness problems. On Windows, the virtual display and selected client must
both advertise compatible HDR support.

## Requirements

Actual limits depend heavily on resolution, frame rate, codec, and encoder.
Treat these as practical starting points rather than purchase guarantees:

- Windows 10 or later, macOS 12 or later, or a current Linux distribution
- A supported hardware encoder (NVENC, VA-API/QSV, or AMF)
- 4 GB RAM
- Wired Ethernet for high-resolution or multi-display streaming; otherwise a
  strong 5 GHz or newer Wi-Fi connection

## Building and testing

Helios uses CMake and includes recursive submodules.

```sh
git submodule update --init --recursive
cmake -S . -B build -DBUILD_TESTS=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

Linux builds require the development packages detected by CMake. Platform
packaging definitions are under `packaging/` and `cmake/packaging/`.

## Support and releases

Report reproducible bugs and request features in the
[Helios issue tracker](https://github.com/moonlight-os/helios/issues).
Published builds are available from
[Helios releases](https://github.com/moonlight-os/helios/releases).

When reporting a streaming problem, include the Helios version, host OS,
encoder, client version, transport, and the smallest reproducible display
layout. Do not post pairing secrets, private keys, Wi-Fi credentials, or full
diagnostic archives publicly.

## License

Helios is distributed under the GNU General Public License v3.0. See
[LICENSE](LICENSE) for the complete terms.
