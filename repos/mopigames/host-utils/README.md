# mlos-host-utils

The host PC half of USB passthrough. One static binary, Windows and Linux,
no dependencies.

Moonlight OS never learns which operating system is at the other end. It says
*"these are the USB devices plugged into me right now"*; this agent works out
whether that means `usbip-win2` on Windows or `/usr/lib/linux-tools/…/usbip`
on Ubuntu, and makes it so.

## Install it on the host PC

### Windows, with winget

```powershell
winget install MopigamesYT.MlosHostUtils
mlos-host-utils install          # from an Administrator terminal
```

winget only puts the binary on your PATH. The second line is what sets up
USB/IP, the boot task and the firewall, and it prints the pairing code.

### Windows, from the releases page

Download `mlos-host-utils-windows-amd64.exe` and **double-click it**. It opens
a wizard: it asks for administrator rights, does everything below, and leaves
the pairing code on screen until you close the window.

If you would rather do it from a terminal, it is the same command winget
users run:

```powershell
# Administrator PowerShell
.\mlos-host-utils-windows-amd64.exe install
```

### Linux

```sh
paru -S mlos-host-utils          # Arch, from the AUR
sudo mlos-host-utils install
```

```sh
sudo ./mlos-host-utils-linux-amd64 install   # anywhere else, from the release
```

On **NixOS**, don't run `install` — it writes a unit and fetches a package,
and a rebuild takes both back. Use the module instead:

```nix
imports = [ inputs.moonlight-os.nixosModules.default ];
services.mlos-host-utils.enable = true;
```

then `mlos-host-utils pair` for the code. See [`packaging/nix`](../packaging/nix).

That one command:

- installs a USB/IP client if there isn't one — usbip-win2 from its latest
  signed release on Windows, the distribution's `usbip` package on Linux
- loads `vhci-hcd` and makes it load at boot (Linux)
- opens the port in the firewall, private networks only
- copies itself to a stable location, so tidying up your Downloads folder
  does not quietly stop the agent coming back after a reboot
- puts that location on your PATH, so `mlos-host-utils` is a command in any
  new terminal (`/usr/local/bin` on Linux; the machine PATH on Windows, so
  terminals already open keep the old one until they are reopened)
- starts the agent at boot: a scheduled task running as `SYSTEM` on Windows,
  a systemd unit on Linux. Both run before anyone logs in and keep running
  while the session is locked, the same as Sunshine's own service
- prints the address and pairing code to type into Moonlight OS, once

Then on the Moonlight OS box: **Devices & input → USB passthrough → Pair this
host PC**. After that, plugging a wheel into the thin client makes it appear
on the host PC, and unplugging it takes it away again.

```
mlos-host-utils status      what's installed, paired and attached
mlos-host-utils pair        print the pairing code again
mlos-host-utils uninstall   remove the service and firewall rule
```

### Surviving a reboot

Linux is a plain systemd unit: `WantedBy=multi-user.target`, root, no session
of any kind, `Restart=on-failure`.

Windows is a boot-triggered scheduled task running as `SYSTEM`, defined from
XML rather than the `schtasks` command line — because three of the
command-line defaults are wrong for something meant to sit there for months:

| Default | Why it had to go |
| --- | --- |
| `ExecutionTimeLimit` 72 hours | the agent is killed after three days and does not return until reboot |
| `DisallowStartIfOnBatteries` true | on a laptop, passthrough silently does not exist until the charger is in |
| `StopIfGoingOnBatteries` true | and it stops mid-session when the charger comes out |

Plus `RestartOnFailure`, which the command-line form cannot express at all,
matching systemd's `Restart=on-failure`.

## Why not usbipd-win

[usbipd-win](https://github.com/dorssel/usbipd-win) is the well-signed,
winget-installable one, and it is the wrong direction: it *exports* devices
from Windows to WSL and Linux guests. It cannot import, and upstream has said
it won't. [usbip-win2](https://github.com/vadimgrn/usbip-win2) is the only
thing that makes a remote device appear as a real one on Windows, so that is
what `install` fetches.

Its driver is signed per release through the Open Source Codesigning
Initiative, so no test-signing dance in the normal case. If Windows does
refuse to load it, `mlos-host-utils testsigning on` is there — it is a
command-line-only escape hatch, never reachable over the network, because it
changes how the machine boots and weakens driver checking. Try without it
first.

## The protocol

Line-delimited JSON over TCP on port **48020**, clear of everything Sunshine
uses (47984–47990, 48010). Every request carries the pairing token; the
comparison is constant-time.

```jsonc
--> {"v":1,"id":"7","token":"…","op":"sync","args":{"devices":[{"busid":"1-2","hwid":"046d:c262","label":"G920"}]}}
<-- {"v":1,"id":"7","ok":true,"data":{"attached":["1-2"],"detached":[],"failed":[],"current":[…]}}
```

| op        | does                                                        |
| --------- | ----------------------------------------------------------- |
| `ping`    | version, OS, whether a USB/IP client is installed and live   |
| `install` | install the USB/IP client if missing                         |
| `sync`    | make the attached set exactly this list                      |
| `attach`  | attach one bus id                                            |
| `detach`  | detach one bus id, or `{"all":true}`                         |
| `list`    | what this peer currently has attached                        |

Two decisions carry most of the weight:

**The USB/IP server address is the TCP peer address.** Moonlight OS never has
to know or send its own address, which is the part that usually breaks — it
has a LAN address, a tailnet address, and no reliable way to guess which one
the host PC can reach it on. Whichever one the connection came in on is by
definition the one that works.

**`sync` is declarative, not incremental.** It says "this is the complete set
I'm offering", and anything attached from this peer that isn't in the list
gets detached. That is what makes unplugging work without Moonlight OS having
to notice which device went away and send a matching `detach`: it re-sends the
list and the missing device is simply absent. Replays are harmless, a dropped
message costs one late update, and the two ends cannot drift.

The agent keeps no state across restarts. `usbip port` is the truth; a cache
would only get to disagree with it.

### Devices that leave without saying goodbye

Pulling the power on the thin client is not a detach. The device stays wedged
in the port table forever and the next attach lands on a second port while the
host keeps talking to the dead one. So the agent probes the servers it has
devices from, and detaches after a minute of no answer — long enough that a
Wi-Fi roam or a tailnet reconnect doesn't cost you the wheel mid-corner.

## Build

Needs Go 1.21+. Nothing else.

```sh
./build.sh          # -> dist/mlos-host-utils-{linux,windows}-{amd64,arm64}
go test ./...
```
