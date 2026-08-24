# Getting started

Helios is the Moonlight OS host. Install it on the computer that runs the
games or desktop you want to stream, then pair Selene or another
Moonlight-compatible client.

## Install

Use a package from
[Helios releases](https://github.com/moonlight-os/helios/releases) when one is
available for your platform. Verify that the release and package originate
from the `moonlight-os/helios` repository.

For a source build:

```sh
git clone --recurse-submodules https://github.com/moonlight-os/helios.git
cd helios
cmake -S . -B build
cmake --build build
```

Platform packaging definitions are kept under `packaging/`. Linux builders
should install the capture, input, audio, encoder, and tray development
libraries reported missing by CMake. Windows virtual-display sessions require
the driver bundled or documented by the release. macOS must grant the screen,
audio, camera, microphone, and input permissions required by the features in
use.

## First launch

1. Start Helios as the same desktop user whose session will be captured.
2. Open [https://localhost:47990](https://localhost:47990) on the host.
3. Accept the locally generated certificate warning only after confirming the
   address is your own Helios host.
4. Create the web-interface credentials when prompted.
5. Add or review applications and verify the chosen encoder and display.

The web interface should normally remain limited to trusted networks. Do not
forward its management port directly to the public Internet.

## Pair a client

1. Put the client and host on the same trusted network.
2. Add the host in Selene. Local discovery usually finds it automatically; an
   IP address can be entered when discovery is unavailable.
3. Start pairing in the client and enter the displayed PIN in Helios.
4. Review the new client's permissions in the Helios web interface.

The first paired client receives administrative permissions. Later clients
start with limited view and app-list access until an administrator grants
launch, input, clipboard, file, or appliance-extension permissions.

## Moonlight OS transport

Selene and Helios negotiate the authenticated QUIC transport per launch.
Classic Moonlight clients continue to use the compatible transport path.
Firewalls must allow the ports shown by the active Helios configuration; do
not assume a copied port list is correct after changing the base port.

USB, microphone, camera, multi-display, and read-only system-disk channels are
session-scoped and individually negotiated. If one is unavailable, check both
the client permission and the host platform support before changing network
settings.

## Encoder and display checks

Before raising resolution or frame rate:

- Confirm that Helios selected a hardware encoder rather than a software
  fallback.
- Test one display at 1080p60.
- Add HDR, higher refresh rates, and extra displays one at a time.
- Prefer wired Ethernet for high-resolution or multi-display sessions.
- On dual-GPU hosts, capture and encode on compatible devices or use the
  documented copy path.

If HDR appears dim or tinted, reproduce the stream in SDR first. HDR requires
compatible host capture, encoder, codec, client decoder, and display metadata.

## Troubleshooting

Start with the smallest reproducible session and save the Helios log before
restarting it. A useful report includes:

- Helios and client versions
- Host operating system and desktop/session type
- GPU and selected encoder
- Client resolution, frame rate, codec, HDR state, and display count
- Whether QUIC or the compatible transport was negotiated
- The first relevant warning or error from the log

Use the
[Helios issue tracker](https://github.com/moonlight-os/helios/issues) for
reproducible defects. Remove pairing secrets, private keys, account tokens,
Wi-Fi credentials, and unrelated personal information from diagnostics before
sharing them.
