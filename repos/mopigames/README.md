# Moonlight OS

A minimal Debian-based OS that does exactly one thing: boot a machine straight
into [Moonlight](https://moonlight-stream.org) streaming.

Boot it, pick your keyboard and Wi-Fi if it doesn't already know them, and
you're in Moonlight. No desktop, no login screen, no package manager staring
at you.

```
power on
   -> install, or try it?       (live USB only, once per boot)
   -> keyboard + time zone      (first boot only)
   -> Wi-Fi                     (only if nothing is connected)
   -> Moonlight, fullscreen
```

Booting the USB stick asks whether to install before it asks anything else.
Installing needs no network and no setup first, so nothing that only the live
session cares about is answered on the way to it — and if the machine already
has Moonlight OS on it, the installer brings the old answers across anyway.

**Ctrl+Alt+M opens Selene's settings panel at any time**, on top of a running
stream. Everything lives there: Wi-Fi, Tailscale, displays, USB passthrough,
health and recovery, backups, and guarded entry points for the installer and
persistence tools. It works mid-stream too, where an ordinary application
shortcut cannot — see the design notes. (Ctrl+Alt+F12 is a fallback that only
works outside a stream.) Quitting Selene still drops you into the console
menu.

With the Windows key sent to the host PC — the default — the running
stream owns the whole keyboard, so leave it with **Ctrl+Alt+Shift+Q** if
Ctrl+Alt+M ever seems dead.

## Build it

Needs `docker` and about 8 GB of free disk. Nothing is installed on your host —
`live-build` runs inside a throwaway Debian container.

```sh
./build.sh                    # -> out/moonlight-os-6.2.1-YYYYMMDD.iso
./build.sh clean              # remove build artifacts, keep the download cache
./build.sh shell              # poke around inside the build container
```

Options:

| Variable            | Default  | Effect                                          |
| ------------------- | -------- | ----------------------------------------------- |
| `ISO_VERSION`       | `6.2.1`  | Version label stamped into the ISO filename     |
| `MLOS_VERSION`      | `0~dev`  | Installed OS version used by the updater         |
| `SELENE_SRC`        | `~/moonlight-os-stuff/selene` | Selene checkout to build the client from |
| `FIRMWARE`          | `full`   | `slim` drops ~400 MB of firmware blobs          |
| `TAILSCALE_VERSION` | latest   | Pin Tailscale instead of taking current stable  |
| `SSH_KEYS`          | `auto`   | Keys allowed in over SSH; `none`, or a path     |
| `MLOS_SUITE`        | `trixie` | Debian release to base on                       |

Write it to a USB stick:

```sh
sudo dd if=out/moonlight-os-6.2.1-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### Keeping it small

There is **no browser**. Firefox was 261 MB on its own and dragged in a
further 61 MB of GTK, Adwaita icons and ATK that nothing else here wanted —
322 MB for a program used once, to finish a Tailscale login. That login now
happens on your phone, via the QR code.

`9000-moonlight-slim.hook.chroot` removes what the packaging drags in and an
appliance never opens.

Two entries in it are now historical, and are kept only because they cost
nothing and something else may drag the same things back in. Both came in
through X11 and left with it:

- **33 MB of C compiler**, via `x11-xserver-utils` — where `xrandr` and `xset`
  came from — depending on `cpp`, because `xrdb` pipes X resource files
  through a preprocessor. Nothing ever ran `xrdb`.
- **~16 MB of PostScript and PDF rendering**, by a genuinely silly route:
  `openbox` → `libobrender` → `imlib2` → `libspectre` → ghostscript, so that
  imlib2 *could* load a PostScript file as a window decoration.

The `locales` package went too. It had never generated anything — `locale.gen`
has no active entries, `/usr/lib/locale` holds only `C.utf8`, and
`/etc/default/locale` says `LANG=C.UTF-8`, which glibc provides by itself. All
15 MB of it was locale source definitions for a `locale-gen` run that never
happens. Keyboard layout comes from `xkb-data` and is unaffected.

What is deliberately **not** trimmed:

- **Firmware, 417 MB** — the single biggest thing left, and the reason the
  image boots on hardware you have not met yet. `FIRMWARE=slim` drops it when
  you know what you are booting on.
- **Mesa's Vulkan drivers (79 MB) and LLVM (150 MB)** — LLVM is not optional,
  since Mesa's *hardware* gallium drivers link it. Vulkan alone could go, at
  the cost of Moonlight's Vulkan renderer and `vulkaninfo` in the diagnostics
  — which are exactly the things you want present when a stream comes up
  black.
- **8 MB of console fonts** — the console font is what the whole settings UI
  is drawn in, and `console-setup` picks it with `CODESET=guess`. Not worth 2
  MB.

### The boot menu, and what to do when it black-screens

Selecting an entry used to be followed by a long, completely black, completely
motionless screen. That is not a hang, but there is no way to tell — GRUB
reads the whole initrd off the stick before the kernel runs and prints nothing
while it does, and the boot line says `quiet splash
vt.global_cursor_default=0`, so there is no text and no cursor either. Then
plymouth comes up on a `#14161A` background, which is very nearly black as
well.

Three things address that:

- **The initrd went from 90 MB to 45 MB**, which halves the wait.
  `MODULES=most` put `amdgpu`, `i915`, `xe`, `radeon` and `nouveau` in the
  initramfs, and initramfs-tools then copied every firmware blob they declare
  — every chip generation of each, because it cannot know what the stick will
  be plugged into. That was 97 MB of a 185 MB initrd, 86 MB of it amdgpu.
  `/etc/initramfs-tools/hooks/zz-moonlight-trim-gpu` takes those drivers off
  the list, so they load from the real root once it is mounted, with the full
  `/lib/firmware` behind them, instead of during early boot. Plymouth draws on
  the firmware framebuffer for the first few seconds rather than on native
  KMS; it looks the same.
- **GRUB now says `Loading Moonlight OS...`** before it starts reading, so the
  gap has something in it.
- **Two diagnostic entries**, added to both bootloaders by
  `0040-moonlight-boot-entries.hook.binary`:
  - **Moonlight OS (verbose boot)** — the normal entry with the silencing
    taken off. Tells you where a boot actually stops.
  - **Moonlight OS (safe graphics, verbose)** — verbose plus `gfxpayload=text`
    and `nomodeset`, which switch off both graphics handoffs: GRUB's
    framebuffer going to the kernel, and the kernel's going to the real GPU
    driver. Those two are the usual reason a screen goes black the instant an
    entry is chosen. If this one shows text and *verbose* does not, that is
    your answer. Streaming will not work on this entry — it is for finding the
    fault, not for running on.

The menu itself only stays up for 3 seconds. Press an arrow key to stop the
countdown.

## Try it without burning a USB stick

```sh
qemu-system-x86_64 -enable-kvm -m 3072 -smp 2 \
    -cdrom out/moonlight-os-6.2.1-*.iso -boot d \
    -vga std -netdev user,id=n0 -device e1000,netdev=n0
```

QEMU has no GPU passthrough, so Moonlight will warn about the missing
hardware decoder — that warning is expected here and does not appear on real
hardware with an Intel or AMD GPU.

## Install to an internal disk

Live USB is fine forever, but if you want it on the machine's own drive, the
welcome screen offers it as the first thing a live boot asks — nothing else
has to be answered to get there. Later on it is Ctrl+Alt+M → **System** →
**Install to this computer**. Either way it wipes the chosen disk, creates two
system slots around a shared boot partition, copies the system into slot A,
and installs GRUB for both UEFI and BIOS. A disk of at least 20 GB is required.
The USB stick you booted from is excluded from the disk list so you can't
overwrite it mid-install.

Confirming the erase means typing a word, which needs the right keys, so the
welcome screen has a keyboard-layout entry alongside the other two. Everything
else on that screen works with the arrow keys, which is why it can come before
the layout has been chosen at all.

If you'd rather keep running from USB, use **System** → **Save settings to
this USB stick** instead — that adds a persistence partition in the stick's
free space so your
pairing, Wi-Fi passwords and display setup survive reboots. Without either
step, a live boot forgets everything on shutdown.

## Built-in OS updates

On an installed system, quit Selene to open the console menu, then choose
**System** → **Update Moonlight OS**. The same guarded updater workflow is
also exposed to Selene's native control-centre API.
The updater downloads the latest release ISO and a small Ed25519-signed
manifest. It verifies the manifest, download size, and SHA-256 hash before it
changes a partition; a bad or missing signature stops the update.

The updater opens on a channel selector. **Stable** follows GitHub's latest
normal release. **Beta** discovers the newest GitHub prerelease tag and then
downloads that tag's signed manifest; drafts and ordinary releases are never
selected by the Beta channel. The selected channel is saved in
`moonlight-os.conf`, survives A/B updates and settings restore, and can be
changed back at any time. Prerelease tags such as `v0.2.8-beta.1` are recorded
inside the signed manifest while the installed version uses Debian ordering
(`0.2.8~beta.1`), so the eventual `0.2.8` stable release correctly supersedes
the beta.

The running system is never rewritten. The new image goes into the inactive
root slot, the machine settings are merged into it, and GRUB tries that slot
once. A system that remains up for 90 seconds marks the new slot as the
default. If it cannot boot that far, GRUB's one-shot choice has already been
consumed, so the following boot automatically returns to the old system.

Installations made by images before the A/B layout have one `moonlight-root`
partition and cannot gain safe rollback in place. They need one reinstall from
a current USB image; the installer's settings hand-off preserves pairing,
network, Bluetooth, Tailscale, SSH identity, and the machine ID. Updates after
that happen from the built-in menu.

Tag releases produce `moonlight-os-update.txt` and its signature alongside the
ISO. Tags containing a prerelease suffix are published as GitHub prereleases
and remain invisible to Stable systems. The repository secret
`MLOS_UPDATE_SIGNING_KEY` holds the private Ed25519 key; the matching public
key is pinned in the image. Changing that key is a trust-root rotation and
must be shipped in an already trusted image first.

## The menus

Ctrl+Alt+M from inside the session, or just quit Moonlight. The top level is
short on purpose — start the stream, then six drawers:

- **Streaming** — auto-connect to a host and skip the launcher, picture quality
  (resolution, frame rate, bitrate, who gets the Windows key), window mode,
  and video problems & logs
- **Displays** — one screen / mirror / extend, and per-screen resolution,
  rotation and position (see below)
- **Sound** — volume, output device, stereo/surround, or play it on the PC instead
- **Devices & input** — Bluetooth, USB passthrough (see below, including a
  recommended safe automatic policy and an explicit all-device policy),
  trackpad, keyboard & time zone, low-battery warnings (see below)
- **Network & internet** — Wi-Fi, Tailscale (see below), remote access over SSH
- **System & maintenance** — live health and diagnostics, full report export,
  video recovery, back up / restore settings, context-aware install or
  persistence actions, command line, and power controls
- **Reboot / shut down**

Everything is stored in `/etc/moonlight-os/moonlight-os.conf`, which is a plain
shell file you can also edit by hand.

## Getting in remotely

`sshd` is on from the first boot, keys only. `build.sh` bakes in every
`~/.ssh/*.pub` from the machine that built the image, so:

```sh
ssh moonlight@moonlight-os.local        # or the IP, or the Tailscale address
```

`SSH_KEYS=/path/to/key.pub` picks a specific key, `SSH_KEYS=none` ships
without any. **Ctrl+Alt+M → Network & internet → Remote access (SSH)** shows
the address and fingerprints, and can turn on a password login if the key
isn't to hand —
the account has passwordless `sudo`, which is why that is off by default.

For working out why a screen or a stream misbehaves, one command collects
the lot:

```sh
ssh moonlight@moonlight-os.local moonlight-report > report.txt
```

That is hardware, kernel DRM messages, the live output layout, VAAPI, Vulkan,
and the compositor's and client's own session log. **System & maintenance →
Health & diagnostics → Save full report** writes the same thing to a mounted
USB drive without leaving the stream.

A live boot with no persistence makes new host keys every time, so your
client will complain about a changed fingerprint on each boot. Installing to
disk, or adding persistence, settles it.

## Streaming from outside the house

**Tailscale** is built in. Ctrl+Alt+M → **Network & internet** → **Tailscale**
→ **Connect / log in** prints an approval link and a QR code. There is no
browser on this image, so finish the login on your phone or another computer —
scan the QR code, or type the link it shows.

Moonlight finds hosts with mDNS, which does not cross a tailnet, so afterwards
add the host PC in Moonlight with **Add PC** and its Tailscale address.
**Host PCs on your tailnet** lists those addresses.

On a live boot with no persistence the login is forgotten at shutdown, the
same as everything else — set up persistence or install to disk to keep it.

## USB passthrough

Two different things, both covered.

**Controllers, headsets, keyboards, mice** work with no setup at all. Moonlight
reads them locally and forwards the input to the host, which is what you want —
it's lower latency than forwarding the USB device itself.

**Specific USB hardware the host needs to see directly** — racing wheels, HOTAS,
pedals, licence dongles — goes over USB/IP. That has a client half that has to
run on the host PC, and this is where every other setup gets tedious: the
command is different on Windows and Linux, Windows ships no USB/IP client at
all, and somebody has to type it at the other end every time.

Helios now owns the host half. USB device offers, attachment traffic and
cleanup travel inside the authenticated streaming session, so there is no
second agent to pair, no extra firewall port, and no device left attached to a
different session.

### Set it up once

Install Helios normally. Its Windows installer includes the pinned, signed
usbip-win2 client; Linux packages install a small privileged helper and depend
on or recommend the distribution's `usbip` tools. Pair Selene with Helios as
usual. That one pairing is the whole setup.

Existing `mlos-host-utils` installations are disabled (not deleted) during a
Helios upgrade. For one transition release, TCP 48020 remains a notice-only
listener explaining that USB moved into authenticated Helios sessions.

### Then plug things in

Turn on **Automatic sharing** and the two machines stay in step: plug a wheel
into Moonlight OS and it appears on the host PC, unplug it and it goes away
again. Nothing to type, nothing to remember, and the same two menu items
whichever operating system is at the other end.

What gets shared is a policy, not a list:

- **Sensible devices only** (the default) — wheels, HOTAS, pedals, dongles,
  printers, MIDI, microphones. Keyboards, mice, speakers, webcams and storage
  stay here: Moonlight already forwards input and playback with less latency
  than USB/IP manages, and video and disks are more than it can carry.

  Microphones are the exception that proves the rule, and it took real
  hardware to notice: the stream carries sound *to* this machine and never
  *from* it, so a mic plugged in here is inaudible to the host unless the
  device itself goes across. Speakers and headphones are skipped, anything
  that can record is shared, and a headset counts as a microphone — so it
  travels whole, and the host both hears you and reaches your ears.
- **Everything plugged in** — exactly that, *including this machine's keyboard
  and mouse*, which then drive the host PC rather than these menus. The menu
  asks twice before turning it on.

Under both, three things are never shared, because losing any of them takes
the running system with it: USB hubs, whatever this machine booted from, and
the network adapter carrying the connection. **Never share these devices…**
adds your own exceptions, by vendor:product id rather than by socket, so
moving the cable doesn't silently change the answer.

**What is plugged in, and what is shared** lists every device with the reason
it is or isn't being handed over, which is the screen to open when something
you expected didn't appear.

### When something goes away

An orderly stream end withdraws the complete device set before disconnecting.
If the stream crashes or the network disappears, Helios tears down that
session's attachments, and the appliance helper releases the devices acquired
by Selene when its dedicated helper connection closes. A tiny runtime journal
also recovers those devices if the helper itself restarts. Manual shares that
predated the stream are never claimed or silently returned.

### Doing it by hand instead

**Share one device by hand** needs no separate agent. It exports the device and
prints the `usbip attach` line for the host PC, which somebody then has to
run — on Windows that means installing
[usbip-win2](https://github.com/vadimgrn/usbip-win2) first, and using the full
path, because `usbip.exe` isn't on the PATH. (The other `usbipd`, the
winget-installable [usbipd-win](https://github.com/dorssel/usbipd-win), is the
wrong direction entirely: it exports devices *from* Windows and cannot import.)

It's the right answer for a one-off on somebody else's computer, and the wrong
one for your own — not least because the clipboard isn't shared over a stream,
so the command has to be retyped at the far end.

### Worth knowing

- Force feedback over a WAN link feels mushy; the round trip is inside the
  loop. On a LAN it's fine.
- Webcams are poor over USB/IP; isochronous transfers and a network are an
  awkward match. USB audio survives it better than expected — a Yeti passed
  from an Atom-based client recorded five seconds at 48 kHz over Wi-Fi with no
  dropped frames — but it is still the first thing to suspect if a stream
  starts crackling.
- USB/IP's port 3240 stays inside the session tunnel. TCP 48020 is no longer a
  working data path and needs no firewall exception.

`tools/test-helper-usb-session.py` covers sharing policy plus native session
ownership, overlap, disconnect and restart recovery.

## The Ctrl+Alt+M hotkey

The settings panel opens on a compositor binding — one line in
`/etc/sway/config`. A compositor evaluates its bindings before the key reaches
any client, so a client holding the keyboard cannot hide it.

That is a recent simplification, and the shape of what it replaced is worth
recording because several other things existed only to serve it. Under X11 the
client held an X keyboard grab while streaming, so the window manager never
saw the combination at all. Working around that took: a `triggerhappy` daemon
reading `/dev/input` directly, evdev rules naming the key twice (positionally,
`KEY_M` is where AZERTY puts the semicolon), a masked `triggerhappy.socket`
because Debian's udev hand-off is broken for USB keyboards plugged in late, a
root-to-user hand-off script to recover a `DISPLAY`, an iconify/restore dance
to make SDL drop the grab, an openbox rule forcing the panel fullscreen so it
shared a layer with the stream, and `xdotool` polling to raise it. All of it
is gone.

**The binding is still positional**, which is the one detail that survived:
`bindsym --to-code` binds the physical key position, so Ctrl+Alt+M lands on
the key labelled M under AZERTY too — the same reason the evdev rules had to
list `KEY_SEMICOLON`.

None of the USB-keyboard trouble that used to live here applies any more
either: `triggerhappy` learned about devices from a start-up glob plus a udev
hand-off that is broken on Debian, so a keyboard on a USB receiver was often
invisible to it and the socket had to be masked. The compositor gets its
devices from libinput and sees hotplugged keyboards without being told.

Nothing shows this on a laptop, where the built-in keyboard is on the i8042
bus, exists before thd starts, and is caught by the glob — the broken path is
never used. Boot the same image on a tablet with a wireless USB keyboard and
the settings menu has no hotkey at all. Masked rather than disabled, thd gets
no socket from systemd, creates its own datagram one at the same path, and
`th-cmd` works.

```sh
sudo ls -l /proc/$(pgrep -x thd)/fd | grep -o '/dev/input/event[0-9]*'
```

is the quick way to see whether thd is actually watching your keyboard.

## Audio on Atom tablets

Two independent faults, both invisible on an ordinary laptop, both fixed in
the image.

**The DSP firmware was missing.** `--no-install-recommends` dropped
`firmware-intel-sound`, so `intel/fw_sst_22a8.bin` never loaded and the Intel
SST DSP never started. The failure is a liar: the card enumerates, the codec
is detected, every driver loads, `aplay -l` lists devices — and then every PCM
open returns `EBUSY`, so PipeWire's profile probe finds nothing usable, offers
only `off` and `pro-audio`, selects `off`, and creates no sink. What you see is
a complete-looking sound menu with a Dummy Output behind it. `alsa-ucm-conf`,
`alsa-topology-conf` and `pipewire-alsa` were missing for the same reason; the
last one is why a plain `speaker-test` bypassed PipeWire entirely.

**The DSP cannot service PipeWire's default buffers.** Once sound worked
locally, streams still had none. The graph settles on a 128-frame quantum —
2.7 ms — and the DSP xruns about a hundred times a second. Every obvious check
says audio is healthy: the ALSA device is `RUNNING` and its `hw_ptr` advances
at exactly realtime. Moonlight logs `Audio packet queue overflow` followed by
`Network dropped audio data`, which reads like a network fault and is not one
— the output never drains a full period, the queue backs up, and the dropped
sequence numbers are the symptom rather than the cause.

`51-moonlight-atom-audio.conf` pins those cards to a 1024-frame quantum. 21 ms
is a lot of audio latency by desktop standards and irrelevant here — the sound
has already crossed a network and been through a decoder. It matches on the
platform driver (`cht-bsw`, `bytcr`, `bytcht`) so a machine with an ordinary
HDA codec keeps its low latency.

## Touchscreens

Rotating a screen does not rotate the touchscreen with it. The panel goes on
reporting where a finger landed in its own coordinates, so on a tablet running
on its side the pointer moves at right angles to the finger — and nothing in X
corrects it by itself.

This matters more than it sounds, because a lot of cheap Atom tablets have a
panel that is physically portrait and *has* to run rotated. On those the
correction is needed on every single boot, not as a one-off.

`moonlight-touch` sets the transform, and `moonlight-displays --apply` calls it
after every layout change — which is also the path session start-up and the
hotplug watcher go through, so it lands everywhere a rotation can.

It finds devices through udev's `ID_INPUT_TOUCHSCREEN` rather than by name.
Name matching looked fine until a real machine turned up with
`FTSC1000:00 2808:1015` and `FTSC1000:00 2808:1015 UNKNOWN` — one a
touchscreen, one not, and setting the property on the wrong one is a
`BadMatch` and an X error on the console.

The matrix is the output's share of the whole screen composed with its
rotation, so it also keeps the touchscreen inside its own panel when a second
monitor is attached rather than letting it span both.

```sh
moonlight-touch --show     # which output, which rotation, which devices
```

## Multiple monitors

`swaymsg` handles the layout; the **Displays** menu drives it. You pick which
screen the client opens on, and a placement rule moves its window there. sway
has no notion of a primary output, so the appliance's own choice is the answer
to that question — under X11 this marked the RandR primary and relied on SDL
putting display index 0 on it.

The menu is two levels and no deeper. The top one is the whole-layout
decision, built from the screens actually plugged in: **Use eDP-1 only**,
**Use HDMI-1 only**, mirror, or extend — one entry per screen, named, so
choosing a layout and choosing which screen Moonlight uses are the same act
rather than two settings that can disagree. **Adjust one screen…** opens the
second level, which is everything about that one screen: resolution, rotation,
where it sits next to the main one, and "open Moonlight on this screen".
Entries that cannot apply — a position for the main screen, a layout choice
when only one screen is attached — are not shown at all. With a single screen
the top level *is* resolution and rotation.

Screens can be **rotated** (for a monitor stood on its end) and **placed**
relative to the main one — right, left, above or below. sway takes absolute
positions and has no `--right-of`, so the placement arithmetic that xrandr
used to do now happens here: a rotated screen is not as wide as its mode says,
so the anchor's *rotated* size is what the neighbour is placed against. Resolution is per screen and can be set back to **Automatic**, which is
not the same as picking today's best mode by hand: swap the monitor and an
override would still pin the old, smaller one.

**Plugging a monitor in or pulling it out is handled on its own.** A watcher
in the session waits on the compositor's output events and rebuilds the layout
for whatever is now attached. It used to poll `xrandr` every couple of seconds,
which was worse than it sounds — see the design notes. If the screen Moonlight was drawing on is the one
that went away, it moves to a surviving screen and restarts — it picks its
display once, at start-up, so nothing else would move it.

Mirroring picks the largest resolution *all* connected screens support, since
mirroring at mismatched resolutions just crops the smaller panel.

The menu asks the running X server what is plugged in, so a monitor connected
after boot shows up — **Look again for screens** re-reads it if you plug one
in while the menu is open. Layout changes take hold immediately; *moving the
stream* to another screen needs Moonlight restarted, because it chooses its
display at start-up.

One stream, one screen. Showing a *second* host monitor at the same time meant
a second Moonlight process against a second Sunshine instance, and that setup
was more trouble than it was worth to run and to explain — it has been taken
out. Extending the desktop across several screens still works; it is the
screens here that extend, not the host PC's.

## Battery warnings

On a laptop, the one machine whose battery matters is the one you are sitting
at — and it is the one nothing can tell you about. Nothing in the streaming
protocol carries the client's system battery to the host (the only battery
field in it is per-gamepad), and a fullscreen app covers any taskbar that
might have shown it. So the warning is drawn on this end, over the stream.

**Devices & input → Battery warnings.** Defaults to 20%, 10% and 5%; the last
level is treated as critical and repeats every five minutes until the charger
goes back in. Pulling the charger out gets its own notice, which is the one
that earns its keep — a plug knocked out of the socket is invisible from
inside a fullscreen app until the machine dies. **Show a test warning now** puts one on
screen so you can check it lands where you expect.

The overlay is a notification, drawn by `mako`. The reason it is a
notification daemon rather than anything of ours is stacking: a Wayland client
cannot place itself above other windows, and layer-shell is the protocol that
exists for the exception. mako draws above a focused fullscreen client
**without taking focus**, which is the property that matters — anything else
would steal focus from the running stream, and that is worse than the warning.

Under X11 this was `osd_cat`, whose window is override-redirect, so openbox
never managed it. Same property, reached a completely different way.

A machine with no battery is detected and the watcher exits; the menu entry
disappears with it. Peripherals are filtered out by `scope=Device`, so a
wireless controller reporting itself as a battery in `/sys/class/power_supply`
never gets mistaken for the machine's own.

## Reinstalling without losing everything

Reinstalling still wipes the disk, even though ordinary releases now use the
built-in updater. The installer handles the hand-off itself: before it erases
anything it looks for an existing Moonlight OS, offers to carry its settings
over, and puts them back into the fresh system afterwards. It looks on every
disk, not just the one being erased — moving from an old drive to a new NVMe
is exactly the case where losing everything hurts most, and there the old
system is sitting somewhere the installer was never going to touch. Failing
that, a
`moonlight-os-settings-*.tar.gz` on any plugged-in medium is offered instead.

Before the disk goes, and again when it is done, it says what it found:

```
Taken from /dev/sda3:

  Moonlight pairing and settings
  Wi-Fi and network: 3 saved connection(s)
  Tailscale login
  Bluetooth: 2 paired device(s)
  Displays, picture quality, sound, USB passthrough
  Keyboard layout and time zone
  SSH host keys and authorised keys
  The SSH account password

Carry all of this over?
```

If the old settings cannot be read, it says so and asks before continuing
rather than quietly installing a system with none of them in it.

**Back up / restore settings** does the same thing by hand, to a USB stick.
What travels:

| | |
| --- | --- |
| Moonlight | client certificate, paired hosts, all its settings |
| Moonlight OS | `moonlight-os.conf`: displays, quality, audio, auto-connect, USB passthrough pairing |
| Network | Wi-Fi passwords, Tailscale login, machine name, SSH host keys, authorised keys, the account password |
| Devices | Bluetooth pairings, keyboard layout, time zone, trackpad, volume |

SSH host keys are in there on purpose: without them every reinstall makes your
client complain about a changed fingerprint. The USB pairing code is in there
too, and it is a credential — anyone holding it can plug USB devices into your
host PC over the network, so the backup stick deserves the same care as the
machine.

Three things make this a merge rather than an overwrite, because a plain
restore quietly loses each of them:

* **`moonlight-os.conf`.** An archive written by an older Moonlight OS has
  none of the keys added since. Dropped on top of the shipped file it takes
  their defaults and their documentation with it, and the newer settings then
  read as missing even though nobody ever changed them. So the shipped file
  stays as the template and only the values move across; a key the image no
  longer ships is appended rather than dropped.
* **`authorized_keys`.** The image carries whoever built it; the archive
  carries whoever the machine trusted. Either one replacing the other locks
  somebody out, so both survive.
* **Wi-Fi connections** are separate files, so they merge on their own.

And three settings are not finished when their file is in place. `/etc/timezone`
is the answer but `/etc/localtime` is what everything actually reads, so the
symlink is repointed; console-setup's cached keymap is deleted so the console
comes back on the layout that just arrived rather than the previous one; and
the account password is spliced back into an `/etc/shadow` that otherwise
belongs to the image — without it a reinstall comes back saying password
logins are on, which is a config file and does travel, while the password
itself is gone.

## Artwork

Everything visual comes from one 200x200 logo, turned into the rest by
`tools/make-boot-art.sh`. The outputs are committed, so an ordinary build
needs neither ImageMagick nor the source file — re-run it only when the logo
changes:

```sh
tools/make-boot-art.sh [path/to/logo.png]
```

It produces the isolinux and GRUB boot screens, a full-size background for the
installed system's GRUB, a 36-frame plymouth throbber (a crimson arc orbiting
the logo, which stays still — it has a swirl in it, and spinning that reads as
a mistake), and a half-block ANSI version for `fastfetch`.

Every `magick` call in it passes `-depth 8`, and that is not cosmetic.
ImageMagick's usual Q16 build writes 16-bit-per-channel PNGs, and GRUB's PNG
reader handles 8 bits and nothing else — it rejects a 16-bit file outright, so
the theme's `desktop-image` never loads and the boot screen comes up with a
garbled logo. The committed artwork is 8-bit; regenerating it keeps it that
way.

`fastfetch` is configured in `/etc/fastfetch/config.jsonc` and shows the
Moonlight-specific facts alongside the usual ones — which host it streams to,
which screen it uses, which layout is in force. The values come from
`moonlight-facts`, which keeps shell out of the JSON. Quitting to the command
line runs it.

## Design notes

Some of these are non-obvious, and a couple were found the hard way:

- **The settings key is a compositor binding.** Under X11 it could not be:
  SDL held an X keyboard grab while streaming, so a window-manager binding was
  useless exactly when it was needed, and the key had to be read off
  `/dev/input` by a separate daemon. A compositor sees the key first, so the
  daemon, its evdev rules and the hand-off script are all gone.

- **Key bindings are positional, not lettered.** `bindsym --to-code` binds the
  key position, so the key labelled M works on AZERTY, where it would
  otherwise be the semicolon. The evdev version needed two rules for this.

- **The guarded terminal-workflow launcher holds a lock directory.** The
  everyday settings UI is Selene's native panel, but install, persistence,
  SSH password setup, and the command line temporarily open the existing
  terminal tools in their own workspace. That wrapper must not `exec` the
  terminal: doing so would drop the `EXIT` trap, leave the lock behind, and
  make the next guarded workflow fail to open. A lock with no matching window
  is treated as stale rather than fatal.

- **sway's `exec` does not own the process it starts.** `startx` tore the X
  server down when its client exited; sway does not, so the session script
  has to end with `swaymsg exit` or the compositor sits there showing an empty
  desktop and the console menu never comes back.

- **`--no-install-recommends` dropped two things that mattered.**
  `firmware-linux-nonfree` only *recommends* `firmware-intel-graphics`, so
  the i915 DMC blob was missing and the kernel logged *"Failed to load DMC
  firmware … Disabling runtime power management"* — which on Gemini Lake is a
  flickering backlight. And nothing pulled in `libgles2`, so Moonlight's EGL
  renderer failed with *"Could not initialize OpenGL / GLES library"* and fell
  back mid-stream. Both are named explicitly in the package list now.

- **Root cannot always overwrite a file in `/tmp`.** `fs.protected_regular`
  refuses to open another user's file for writing in a sticky, world-writable
  directory, root included. The installer saving a backup over one you made
  yourself hit exactly that, so the archive is unlinked before it is written.
  It only became findable once the code stopped sending tar's stderr to
  `/dev/null`.

- **plymouth's two-step plugin fails silently without its UI assets.** A
  theme needs `entry.png`, `bullet.png`, `lock.png` and friends — the bits
  only ever drawn for a password prompt, which this appliance never shows.
  Without them the plugin refuses to start and plymouth falls back to three
  grey dots, with nothing in any log to say why. The looping animation is
  `throbber-*.png` too; `animation-*.png` is a one-shot intro that plays once
  and leaves an empty screen behind.

- **`/etc/os-release` is a real file here, not the usual symlink** into
  `/usr/lib`, so branding the name means writing both. Only `PRETTY_NAME` and
  the URLs are touched: `ID` and `VERSION_ID` stay Debian's, because package
  tooling keys off them.

- **Borderless is the default window mode.** Exclusive fullscreen makes
  Moonlight ask the monitor to switch to the stream's resolution. When the
  panel has no matching mode the modeset is retried, which looks like the
  backlight flashing on and off and ends in "connection terminated". Both are
  in **Video & logs**; borderless covers the screen without touching the mode.

- **Two ways to set the window mode.** The direct-stream path takes
  `--display-mode` on the command line, but the launcher reads it out of Qt's
  own settings file, so `/usr/local/bin/moonlight` seeds `windowmode` there
  before starting (`0` fullscreen, `1` borderless, `2` windowed). Resolution,
  frame rate, audio and the rest go the same way.

- **The stream defaults to the screen's own resolution.** Moonlight's own
  default is 1280x720, which on a box wired to a 1080p panel is a blurry
  picture nobody asked for. An empty `STREAM_WIDTH` means "read it off
  the compositor".

- **"Automatic" bitrate means deleting the key, not setting it to zero.**
  Moonlight computes a default from the resolution and frame rate only when
  `bitrate` is absent; a zero is just a zero. (And the key is `bitrate` —
  `bitrateKbps` is the name of the C++ member, not the stored setting.)

- **The Windows key and Ctrl+Alt+M cannot both work during a stream.** With
  `capturesyskeys` on, SDL grabs the whole keyboard so Super and Alt+Tab
  reach the host PC, and the window manager sees nothing. The default is to
  give the keys to the PC — that is what a streaming box is for — and to
  leave the stream first with Moonlight's own Ctrl+Alt+Shift+Q. **Stream
  quality → Who gets the Windows key** flips it.

- **Threads are allowed to raise their priority.** Without the `limits.d`
  drop-in, Moonlight's render and audio threads are refused and say so in the
  log, costing frame pacing and adding audio crackle.

- **Tailscale comes from the upstream static tarball,** not an apt repo —
  Debian does not package it, and the alternative is shipping and trusting a
  third-party signing key at build time. `build.sh` asks
  `pkgs.tailscale.com` what stable is, or takes `TAILSCALE_VERSION`.

- **`tailscaled` waits for Wi-Fi, and never gives up.** The unit in that
  tarball is ordered after `NetworkManager.service`, which is up long before
  anything has associated — so on a machine with no cable, tailscaled started
  with no route anywhere, failed, and its `Restart=on-failure` hit systemd's
  default rate limit within a second or two. It then stayed dead for the rest
  of the boot and the Tailscale menu reported a daemon that was not
  responding. The fetched unit is taken as it ships and corrected from
  `tailscaled.service.d/` beside it: ordered after `network-online.target`
  (`Wants=`, so an appliance with no network still boots), with no start
  limit and `Restart=always`. A dispatcher script in
  `/etc/NetworkManager/dispatcher.d` starts it the moment a connection comes
  up, which is the first-boot case the ordering cannot cover — there is no
  saved network to wait for yet, so the user picks one minutes later. It
  leaves a running daemon alone: restarting on every reconnect would drop the
  tailnet exactly when it is wanted.

- **Wayland, not X11.** The session is `sway`: compositor, window manager and
  hotkey daemon in one, where X11 needed Xorg plus openbox plus triggerhappy
  plus xdotool. This became possible when the client became Selene, built from
  source with the Wayland QPA, rather than an AppImage shipping only `xcb`.
  Xwayland is not installed and is disabled in the config: nothing here needs
  X, so shipping an X server to run nothing would be the only reason it
  existed.

  The client needs `qt6-wayland` at runtime. Qt dlopens its platform plugin,
  so nothing links against it and no dependency resolver pulls it in — without
  it Qt finds no usable platform and the client aborts on start. Selene's
  package names it explicitly for that reason.

- **A .deb, not an AppImage.** The client is Selene, our fork of moonlight-qt,
  built from source by `build.sh` into a real Debian package and staged in
  `config/packages.chroot/`. Upstream Moonlight ships x86 as an AppImage only
  (its Cloudsmith apt repo publishes arm64, armhf and riscv64 — the amd64
  `Packages` file is empty), and that AppImage carried a second copy of Qt,
  SDL, FFmpeg and libva.

  This is **not** a size win, which is worth stating plainly because it looks
  like it should be. Dropping the 145 MB AppImage means the image has to carry
  Debian's Qt6 (46 MB) and its QML modules instead, and after squashfs the ISO
  lands about 13 MB *larger* than the AppImage build. What it buys is
  correctness: the client links the same libva, Mesa and FFmpeg as everything
  else in the image, which removed two standing hacks — the
  `LIBVA_DRIVERS_PATH` override, needed because the bundled libva was built
  against a different prefix, and the `pkill -x AppRun` restart fallback, which
  matched a name belonging to the AppImage runtime rather than to the client.

- **`libgpg-error0` is not optional.** `libqxcb.so` pulls in `libgcrypt` →
  `libgpg-error`, and Debian doesn't install the latter by default under
  `--no-install-recommends`. Without it Qt can't load its platform plugin and
  the client never draws a window. It now arrives as a dependency of Debian's
  Qt rather than of a bundled copy, but it is still listed explicitly.

- **Keyboard before Wi-Fi.** The region wizard runs first on purpose: on a
  non-US layout, every character of a Wi-Fi password typed at the network
  prompt would otherwise be wrong.

- **Wi-Fi power saving is disabled.** It parks the radio between packets and
  adds tens of milliseconds of jitter — fatal for streaming.

- **`wpa_supplicant.service` is deliberately left enabled.** NetworkManager
  D-Bus-activates it; masking it kills Wi-Fi entirely.

- **live-config's `xinit` component no longer needs switching off.** It used
  to be disabled on the kernel command line: it installs
  `/etc/profile.d/zz-live-config_xinit.sh`, which runs
  `while true; do startx; done` from `/etc/profile`, blocking before
  `~/.bash_profile` is ever read — so the appliance never started and you got
  a bare openbox desktop instead. With no X server in the image there is
  nothing for it to start. The installer still deletes the snippet on the
  target disk.

- **Settings are written through `sudo`.** `/etc/moonlight-os/moonlight-os.conf`
  is root-owned and the menus run as the session user. Writing it with a plain
  redirect fails with EACCES *and returns success*, because the failure is on
  the redirect rather than the command — so every saved setting silently
  vanished while the UI reported it had saved.

- **The installer reads the new UUIDs through `sudo` too,** for the same
  reason: `blkid` has to open the raw device, and run as the session user it
  prints nothing and exits 0. The fstab then said `UUID=` for both
  filesystems and the installed system came up in emergency mode.

- **Menu items are passed after `--`.** whiptail treats any argument starting
  with `-` as an option, so a network named `-guest` or a description with a
  leading dash would otherwise make the whole menu fail to open.

- **The console keymap comes from `setupcon`, not `loadkeys`.** There is no
  `console-data` in the image, so `loadkeys be` has no keymap file to read;
  `setupcon` builds one from the XKB data with `ckbcomp`. It also needs
  `--save`, not `--save-only` — the latter writes the cache without applying
  anything.

## Layout

```
auto/config                             live-build options
build.sh                                containerised build driver
config/package-lists/                   the entire package set
config/hooks/normal/                    user creation, services, image slimming
config/includes.chroot/
    etc/                                autologin, sudoers, udev, sysctl, NM
    usr/local/bin/moonlight-*           the appliance itself
```

The scripts are POSIX `sh` and readable in one sitting:

| Script                | Role                                              |
| --------------------- | ------------------------------------------------- |
| `moonlight-session`   | boot flow: welcome → region → network → X → menu  |
| `moonlight-welcome`   | live boot's first question: install, or try it?   |
| `moonlight-wlsession` | the session sway runs: layout, keymap, then Selene |
| `moonlight-panel`     | guarded terminal launcher for install, persistence, SSH and shell |
| `moonlight-hotkey`    | hands Ctrl+Alt+M between Sway and the in-stream Selene panel      |
| `moonlight-helper`    | narrow privileged API used by Selene's native panel           |
| `moonlight-netsetup`  | Wi-Fi wizard                                      |
| `moonlight-tailscale` | tailnet login and peer list                       |
| `moonlight-ssh`       | remote access: address, fingerprints, password    |
| `moonlight-report`    | one-shot diagnostic dump on stdout                |
| `moonlight-displays`  | multi-monitor layout                              |
| `moonlight-stream`    | resolution, frame rate, bitrate, system keys      |
| `moonlight-audio`     | volume, output device, stereo/surround            |
| `moonlight-bluetooth` | pairing, connecting, forgetting devices           |
| `moonlight-battery`   | low-battery watcher, warns over the stream        |
| `moonlight-osd`       | one line of text over the top of everything       |
| `moonlight-region`    | keyboard layout + time zone                       |
| `moonlight-usb`       | USB/IP passthrough                                |
| `moonlight-usb-auto`  | retired TCP-agent compatibility watcher        |
| `moonlight-touch`     | points the touchscreen the same way as the screen |
| `moonlight-hostagent` | retired TCP-agent compatibility client         |
| `moonlight-install`   | install to internal disk                          |
| `moonlight-update`    | signed A/B OS updates and boot confirmation       |
| `moonlight-persist`   | persistence partition on the boot USB             |
| `moonlight-menu`      | the menu shown when Moonlight exits               |

## Limitations

- **amd64 only.** Selene is built for amd64. For a Raspberry Pi it would need
  cross-building or building on the target, plus `MLOS_ARCH`. Untested.
- **NVIDIA GPUs use the nouveau driver**, which has no usable video decode on
  recent cards. Intel and AMD get full VAAPI hardware decoding. If your client
  box has an NVIDIA card, add `nvidia-driver` to the package list.
- A monitor plugged in while Moonlight is running needs **Displays → Look
  again for screens** before it shows up. Layout changes apply immediately,
  but *moving the stream* onto a different screen needs Moonlight restarted —
  it picks its display when it starts.
