# pbxvm — Asterisk + TFTP for the Cisco CP-8851

A vacuvm on prophecy (tag 6, `10.78.77.6` / `2602:fce8:106:10::6`) that does two
jobs: TFTP-provisions one Cisco IP Phone 8851 and gives it dial tone through a
Telnyx SIP trunk.

## Why it looks like this

- **The phone runs Cisco's _enterprise_ (Unified CM) SIP firmware**, not the
  multiplatform (MPP) firmware. That decides everything about provisioning: the
  phone TFTPs `SEP<MAC>.cnf.xml` in CUCM's XML schema and takes its whole
  identity — proxy address, line, credentials, dial rules — from that one file.
  There is no per-setting web UI to fall back on.
- **The phone talks SIP over TCP** (`<transportLayerProtocol>1</…>`). The
  enterprise firmware's UDP path retransmits aggressively against anything that
  isn't a real CUCM; TCP is the well-trodden combination with Asterisk. The
  `1001` pjsip endpoint is pinned to `transport-tcp` to match.
- **Two channel drivers, one PBX.** The enterprise firmware expects a pile of
  Cisco-proprietary SIP for its softkeys — BLF, call park, DND sync,
  conferencing, directories — which stock Asterisk does not speak. The
  <https://usecallmanager.nz/> patch adds it, and carries it on **chan_sip**,
  which upstream deleted in Asterisk 21 and the patch reintroduces wholesale.

  So the phone is a `chan_sip` peer in `sip.conf` with `cisco=yes`, and the
  Telnyx trunk stays a `chan_pjsip` endpoint. The two stacks are independent and
  cannot share a bind, so chan_sip keeps 5060 (which is what the phone is told
  and what it falls back to) and chan_pjsip moves to 5062. Only outbound
  registration uses the latter, so the number is arbitrary — Telnyx replies to
  whatever source port the REGISTER came from.

  The patched build is `packages/asterisk-usecallmanager`. It pins one exact
  Asterisk release, because the patch is cut against one and will not apply to
  another; a nixpkgs bump fails the build with an explicit message rather than
  quietly producing an unpatched asterisk under a patched name.
- **The phone reaches the VM directly, no router changes.** The vacuvm net
  `10.78.77.0/24` is _inside_ the LAN's `10.78.76.0/22`, so the phone thinks
  `10.78.77.6` is on-link and ARPs for it — and prophecy's `IPv4ProxyARP` on
  `br-main` answers. That is also why asterisk's `local_net` is the whole `/22`:
  everything on the LAN gets the VM's own address in SDP.
- **The trunks see prophecy's Doof address.** Guest traffic is policy-routed out
  `wg-doof` and SNATed to `205.201.63.13` (`hosts/prophecy/doof.nix`), so the
  pjsip transport carries `external_media_address` /
  `external_signaling_address` = that address. Inbound calls rely on `line=yes`
  on each outbound registration: the provider sends the INVITE back through the
  same flow the REGISTER opened, which is what survives the SNAT. Each AOR's
  `qualify_frequency=30` doubles as the keepalive that stops conntrack dropping
  that mapping.
- **Two trunks, two line buttons.** `vacu.pbx.trunks` generates a pjsip
  endpoint/aor/registration set and a `from-<name>` inbound context per
  provider, so adding a third is a few lines.

  Each trunk also gets a **line button on the handset**, and that is how you
  choose which way a call goes out. Every button is a SIP registration of its
  own — 1001 for Telnyx on button 1, 1002 for JMP.chat on button 2, counting up
  from `vacu.pbx.extension` — so the button a call was placed on arrives at
  asterisk as _which chan_sip peer sent the INVITE_. Each peer has its own
  `from-phone-<trunk>` context whose only job is to `Set(TRUNK=…)` before
  handing off to the shared dialplan. Nothing is dialled to select a trunk, so
  nothing interferes with the dial rules, and the normal timeouts apply
  unchanged.

  Inbound, each trunk rings its own line, so the button that lights up tells you
  which of your numbers was called.

  `dialPrefix` still exists as a second way in — a prefix that forces a trunk
  from any line — but no trunk sets one now.
- **The VM is the phone's NTP server.** An 8851 in SIP mode has no other source
  of time, so chrony runs here with `allow 10.78.76.0/22` and the XML points
  `<ntps>` at `10.78.77.6`.

## Files

| File                                | What                                                            |
| ----------------------------------- | --------------------------------------------------------------- |
| `hosts/pbxvm/default.nix`           | Host basics plus the `vacu.pbx.*` options everything else reads |
| `hosts/pbxvm/asterisk.nix`          | chan_sip line peers, pjsip trunks, dialplan, firewall           |
| `packages/asterisk-usecallmanager/` | Asterisk + the usecallmanager.nz patch                          |
| `hosts/pbxvm/tftp.nix`              | atftpd, `SEP<MAC>.cnf.xml`, `dialplan.xml`                      |
| `hosts/pbxvm/secrets-guard.nix`     | Refuses to start either service when sops has not rendered      |
| `hosts/prophecy/vms.nix`            | The VM itself (tag 6)                                           |
| `secrets/hosts/pbxvm.yaml`          | Telnyx password + the line's SIP password                       |

Both passwords are sops-rendered at runtime (`sops.templates`) rather than baked
into the store — including the one inside `SEP<MAC>.cnf.xml`, which sops writes
straight into `/srv/tftp`. Note TFTP then hands that file to anyone on the LAN
who asks for the right name; the real protection there is that the LAN is
trusted, not the file mode.

## Bringing it up

### 1. Deploy

```bash
# on prophecy: picks up the new tap, its routes/policy rules, and the units
nixos-rebuild switch --flake .#prophecy

toplevel=$(nix build .#nixosConfigurations.pbxvm.config.system.build.toplevel \
  --no-link --print-out-paths)
vacuvm bootstrap pbxvm "$toplevel"
systemctl start vacuvm-pbxvm-qemu
```

### 2. Finish the secrets

**Nothing works until this step is done.** `secrets/hosts/pbxvm.yaml` is
committed with `REPLACE-ME-…` placeholders and is encrypted only to the user
keys — the VM had no host key when it was written, so sops-nix on pbxvm cannot
decrypt it. Both of the files it renders are load-bearing: asterisk `#include`s
one and refuses to start without it, and the other _is_ the phone's config file.

```bash
# once the VM has booted and generated its host key
ssh-keyscan 10.78.77.6
# put the ed25519 key in common/hosts.nix under `pbxvm.ssh.keys`, then:
./sops updatekeys secrets/hosts/pbxvm.yaml   # re-encrypt, now including the VM
./sops secrets/hosts/pbxvm.yaml              # fill in the two real passwords
git add common/hosts.nix secrets/hosts/pbxvm.yaml   # flakes only see tracked files
```

- `telnyx.password` — the password of the Telnyx **credential connection** whose
  username is `usertelnyx97122`.
- `jmpchat.password` — the JMP.chat / Bandwidth password for `c4986875698`.
- `phone.1001.password` — invent one. It only has to match between asterisk and
  the XML, and this repo puts it in both. Every line button shares it: they are
  the same handset on the same trusted LAN, and one secret is one thing to
  rotate. So adding a trunk needs no new secret beyond its own password.

Then rebuild and deploy pbxvm. The asterisk _unit_ does not change when only the
ciphertext does, and it is `restartIfChanged = false` besides (so a rebuild
never drops a live call), so restart it by hand afterwards:

```bash
systemctl restart asterisk
```

### 3. Point the phone at the TFTP server

Nothing hands out DHCP option 150 on this LAN, so set it on the handset:

**Settings → Admin Settings → Network Setup → IPv4 Setup → Alternate TFTP →
On**, then **TFTP Server 1 → `10.78.77.6`**. Save; the phone reboots.

If the phone has ever been registered to a real CUCM it holds an ITL and will
refuse this unsigned config. Clear it: **Settings → Admin Settings → Security
Setup → Trust List → ITL File**, unlock with `**#`, then **Erase**. A full
factory reset (hold `#` while powering on, then dial `123456789*0#`) does the
same and more.

### 4. Check

```bash
# on pbxvm
journalctl -fu atftpd                       # watch the phone fetch SEP….cnf.xml
asterisk -rx 'pjsip show registrations'     # telnyx and jmpchat → Registered
asterisk -rx 'sip show peers'               # 1001 and 1002 → one row each, with
                                            # a host:port, i.e. both lines are up
```

Both line peers must show a contact. A handset that registers only 1001 has
taken a stale config: it has one line button and no way to reach JMP.chat.
Re-read the config (see below) and check the phone's **Settings → Phone
Information**.

Then dial **611** from the handset for an echo test — that proves RTP between
phone and PBX without involving Telnyx or spending money. After that, dial a
real number.

### SSH on the handset

Off by default; the web UI reports it as **SSH access enabled: No**, which is
this repo's `<sshAccess>1</sshAccess>` doing exactly what it was told (`0`
enables, `1` disables — same inverted encoding as `webAccess`).

It needs a password, so add one to the secrets file _before_ turning it on —
otherwise sops cannot render the phone's config and atftpd refuses to start:

```bash
./sops secrets/hosts/pbxvm.yaml     # add phone.1001.sshPassword
git add secrets/hosts/pbxvm.yaml
```

then set `vacu.pbx.sshAccess = true;` and rebuild. The username is
`vacu.pbx.sshUser` (default `cisco`). The phone re-reads its config on boot
only, so push it with `sip notify cisco-restart 1001` or reboot the handset.

Logging in lands you in a restricted shell. On the 8800 series, username `debug`
and password `debug` from there reaches the actual debugging shell.

### Pushing a config change to the phone

The phone reads its TFTP files **when it boots, and at no other time** — there
is no polling interval, so editing `dialplan.xml` or `SEP<MAC>.cnf.xml` on the
server changes nothing by itself. (Repeated fetches in the atftpd log are the
failure-retry loop, not polling: a phone that got a usable config stops asking.)

Three ways to make it re-read, cheapest first:

```bash
asterisk -rx 'sip notify cisco-restart 1001'   # quick restart
asterisk -rx 'sip notify cisco-reset 1001'     # full boot cycle
```

That is CUCM's mechanism: a NOTIFY carrying `Event: service-control`, where
all-zero version stamps mean "everything you have cached is stale". It also
carries `RegisterCallId={<the phone's REGISTER Call-ID>}`, which the phone
checks before acting — supplied by the patch's `SIP_PEER()`, and the reason this
moved off chan_pjsip, which has no way to reach that value.

Failing that, reboot the phone from **Settings → Admin Settings → Restart**, or
pull its PoE. Those always work.

### Troubleshooting: the phone sits on "Phone is registering"

First check asterisk is actually listening — `pjsip show transports` should list
two. If it lists none, look for this in the journal:

```
The file '/run/secrets/rendered/pjsip-secrets.conf' was listed as a #include but it does not exist
Contents of config file 'pjsip.conf' are invalid and cannot be parsed
```

That means step 2 above is unfinished. Asterisk discards the **whole** config
file when an `#include` target is missing, so the result is a PBX with no
transports and no endpoints at all — the phone has nothing to register to.
`hosts/pbxvm/secrets-guard.nix` now refuses to start asterisk (and atftpd) in
that state rather than letting it come up hollow, so the more likely symptom
today is a failed unit naming the missing file.

Two log-reading traps worth knowing:

- **atftpd's `Serving <file> to <ip>` line is printed when the request arrives,
  before the file is opened** (`tftpd.c`, `GET_RRQ`). It is not evidence that
  anything was delivered. A phone that keeps re-requesting the same short list
  of files every ~45s is a phone that is _not_ getting a usable config.
- The phone always asks for `CTLSEP<MAC>.tlv`, `ITLSEP<MAC>.tlv`, `ITLFile.tlv`
  and `AppDialRules.xml`. All four are absent on purpose and their failures are
  normal. `dialplan.xml` is the one to watch for: the phone only asks for it
  after it has parsed `SEP<MAC>.cnf.xml`, so its absence from the log means the
  config never took.

## Dialling

### Picking a trunk

Press the line button for the trunk you want — **Telnyx** on button 1, **JMP**
on button 2 — then dial. Off-hook without pressing one takes button 1, so Telnyx
stays the no-thought default (`vacu.pbx.defaultTrunk` decides which trunk that
is, and it is always button 1).

The labels next to the buttons come from each trunk's `label`; the dialling
rules below are the same on every line.

### Numbers

- 10 digits (`5555550123`), 11 (`15555550123`), or `+1…` — all normalised to
  E.164 and sent to Telnyx.
- Every rule is anchored on a literal leading digit (`1..........`, then
  `2.........` through `9.........` for the ten-digit case). `.` matches any
  character, so a bare ten-dot rule also matches the first ten keys of
  `011 49 30 …`, and being the longer pattern it beats `011*` — the phone would
  dial a truncated international number the moment the tenth key landed.
  Anchoring on 1-9 keeps the local rules clear of the leading `0` that every
  international dial string starts with. There is no `[2-9]` range syntax to do
  this in one rule; it appears in some Cisco examples but is not among the
  documented pattern characters.
- `011` + country code for international. `vacu.pbx.perCountryDialRules`
  generates a `Timeout="0"` rule per **(country code, leading-digit prefix)**
  from libphonenumber's metadata — about 2400 rules, 116 KiB — so the call sends
  the instant the number is unambiguously complete.

  Branching on leading digits, rather than one length per country, is what makes
  it worth the size. A country's overall maximum is usually set by some rare
  long service range, so a per-country rule almost never fires: Tokyo numbers
  are 9 digits but +81 runs to 17, Sydney is 9 but +61 runs to 12. Splitting on
  the first digits collapses those to the length that actually applies. Across
  every example number libphonenumber ships, instant dialling goes from **56% to
  85%**.

  It cannot make a number undialable. The length attached to a prefix is the
  maximum over every number type whose pattern that prefix could still grow
  into, so it is never shorter than a real number starting that way. Countries
  with genuinely open numbering never tighten and keep falling through to the
  `011*` timeout — a German landline is 5 to 15 digits and every Vorwahl reaches
  15, so Germany gets no benefit at all and is unchanged.

  The generator re-checks that at build time against all 1128 example numbers
  and **fails the build** rather than emit a rule that would dial one truncated.
  Set the option to `false` for the 16 hand-written rules if the handset ever
  chokes on the size.

- `611` — local echo test, on either line.
- A call inbound on a trunk rings that trunk's line button.

`vacu.pbx.trunks.telnyx.outboundCallerId` is unset, so Telnyx picks the
connection's default caller ID. Set it to an E.164 number you own to override.

## Things that will need attention later

- `vacu.pbx.trunks.telnyx.signalingIps` is Telnyx's _US_ signalling pair from
  <https://sip.telnyx.com/>. If the connection moves region, or Telnyx
  renumbers, update it (inbound would still work via `line=yes`, but the
  `identify` would stop matching).
- No voicemail, no second handset, no CDR storage. All are additions to
  `hosts/pbxvm/asterisk.nix` rather than rework.
- `<loadInformation>` is deliberately absent from the XML, so the phone keeps
  whatever firmware it has. Upgrading it means putting the `.loads`/`.sbn` files
  in `/srv/tftp` and naming the load there.
