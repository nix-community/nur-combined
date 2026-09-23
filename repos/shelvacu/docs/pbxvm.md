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
  choose which way a call goes out. Each button is a chan_sip peer of its own —
  1001 for Telnyx on button 1, 1002 for JMP.chat on button 2, counting up from
  `vacu.pbx.extension` — so the button a call was placed on arrives at asterisk
  as _which peer sent the INVITE_. Each peer has its own `from-phone-<trunk>`
  context whose only job is to `Set(TRUNK=…)` before handing off to the shared
  dialplan. Nothing is dialled to select a trunk, so nothing interferes with the
  dial rules, and the normal timeouts apply unchanged.

  They are not independent registrations, and that is the part that bites: the
  enterprise firmware sends **one REGISTER, for the primary line**, and holds
  **one device-wide digest credential**. So every `<line>` in the phone's config
  carries the _primary_ line's `authName`/`authPassword`. Give them one each and
  the phone answers the primary line's own challenge as 1002, asterisk rejects
  it with `Authorization username mismatch`, and the handset never gets past
  "Phone is registering".

  chan_sip is built for exactly this. The primary peer lists the others in
  `register=`, which hands each of them the primary's registration — address,
  socket, secret, a contact rebuilt as its own name at the phone's address, and
  a line index counting from 2 in the order listed. That index above 1, together
  with `cisco=yes`, is also how a peer knows to expect the primary's name in the
  digest username rather than its own. Context, callerid and dialplan stay the
  line's own, which is what leaves room for the scheme above.

  Inbound, each trunk rings its own line, so the button that lights up tells you
  which of your numbers was called.

  `dialPrefix` still exists as a second way in — a prefix that forces a trunk
  from any line — but no trunk sets one now.
- **KPML is off (`<kpml>0</kpml>`), or the phone cannot dial at all.** Left on —
  the firmware default — the phone collects digits the CUCM way: it sends an
  INVITE carrying only the **first keypress** and expects to report the rest
  over a KPML subscription. This chan_sip has no KPML (the string does not occur
  anywhere in the patch), so it replies `484 Address Incomplete` and the handset
  plays reorder the moment the first digit lands. The symptom is total: every
  call dies on digit one, and asterisk logs nothing but two `ast_set_qos` lines,
  because the 484 path in `handlers.c` is silent.

  With it off the phone collects digits itself and sends one INVITE with the
  whole number. See the dial-rules note under Dialling for when that is instant
  and when it waits.
- **Provisioning goes over HTTP, with TFTP as the fallback.** The phone tries
  HTTP on port 6970 of its TFTP server for every file it wants, and only falls
  back to TFTP when that fails. Its TFTP client is slow in a way no server can
  fix: every transfer loses its first packet — the phone tries IPv6 first and
  its own log says `sendto() failed: Address family not supported` — then waits
  out a 500 ms retransmit timer, serially, so files land 6.6 seconds apart.

  Measured on this handset, same files, same directory:

  | transport | the boot's fetching | to both lines registered |
  | --------- | ------------------- | ------------------------ |
  | TFTP      | ~45 s               | ~80 s                    |
  | HTTP      | 5–7 s               | ~10 s                    |

  `services.darkhttpd` serves it: three static files, read only, one handset, no
  config file. It binds `::` rather than `0.0.0.0` because the module passes
  `--ipv6` whenever the host has IPv6 and darkhttpd binds one socket; with the
  kernel's default `bindv6only=0` that covers IPv4 too, arriving v4-mapped, the
  same way atftpd already logs the phone as `::ffff:10.78.78.249`. The port is
  hardcoded in the firmware (6971 is its HTTPS port, which wants an ITL this
  setup does not have).
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
| `hosts/pbxvm/http.nix`              | the same files over HTTP, which is what the phone prefers       |
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
journalctl -fu darkhttpd                    # watch the phone fetch SEP….cnf.xml
journalctl -fu atftpd                       # only if HTTP failed and it fell back
asterisk -rx 'pjsip show registrations'     # telnyx and jmpchat → Registered
asterisk -rx 'sip show peers'               # 1001 and 1002 → one row each, with
                                            # a host:port, i.e. both lines are up
```

Both line peers must show a host:port. 1002 gets its one from 1001's
registration (`register=` in `sip.conf`), so it appears a moment after the phone
registers and not before — if 1001 is unregistered, both look dead.

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

- The phone normally provisions over HTTP, so `darkhttpd`'s log is the one to
  watch; atftpd staying silent is correct, not a fault.
- **atftpd's `Serving <file> to <ip>` line is printed when the request arrives,
  before the file is opened** (`tftpd.c`, `GET_RRQ`). It is not evidence that
  anything was delivered. A phone that keeps re-requesting the same short list
  of files every ~45s is a phone that is _not_ getting a usable config.
- The phone always asks for `CTLSEP<MAC>.tlv`, `ITLSEP<MAC>.tlv`, `ITLFile.tlv`
  and `AppDialRules.xml`. All four are absent on purpose and their failures are
  normal. `dialplan.xml` is the one to watch for: the phone only asks for it
  after it has parsed `SEP<MAC>.cnf.xml`, so its absence from the log means the
  config never took.

If the phone _is_ getting its config and still sits there, look for this:

```
Authorization username mismatch for SIP peer '1001' response has '1002'
SIP registration for peer '<sip:1001@10.78.77.6>' … failed because 'Username mismatch'
```

That is the one-credential-per-device behavior described above: the phone is
answering the primary line's challenge with some other line's `authName`. Every
`<line>` has to carry the primary line's `authName`/`authPassword`, and each
secondary line peer has to be in the primary's `register=`. Both are generated,
so in practice this means the handset is running an older config than the server
has. Restart it and watch atftpd log the fetch — and note
`sip notify
cisco-restart` is no use here, since it needs the Call-ID of a
REGISTER that by definition never succeeded. Reboot from **Settings → Admin
Settings → Restart**, or pull the PoE.

### Troubleshooting: the error tone starts on the first digit

Every outbound call dies the instant a key is pressed, and asterisk's journal
shows only this per attempt, with no `Executing [...]` line:

```
netsock2.c: Using SIP audio TOS bits 184
netsock2.c: Using SIP audio CoS mark 5
```

That is KPML: the phone sent an INVITE carrying one digit, and chan_sip replied
`484 Address Incomplete` down the silent path in `handlers.c` (the logged
rejection at NOTICE is only for `404`, so a 484 leaves no trace at all). Check
`<kpml>0</kpml>` is in the phone's config and that the handset has re-read it.

To see the digit for yourself, read the INVITE out of the phone's own log rather
than guessing:

```bash
curl -s http://<phone-ip>/FS/messages | grep -A6 'INVITE sip:'
# To: <sip:4@10.78.77.6>      <- one keypress, which matches no extension
```

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
  from libphonenumber's metadata — 2404 rules, 117 KiB for every country, of
  which about 8 KiB fits — so the call sends the instant the number is
  unambiguously complete.

  Branching on leading digits, rather than one length per country, is what makes
  it worth the size. A country's overall maximum is usually set by some rare
  long service range, so a per-country rule almost never fires: Tokyo numbers
  are 9 digits but +81 runs to 17, Sydney is 9 but +61 runs to 12. Splitting on
  the first digits collapses those to the length that actually applies. Across
  every example number libphonenumber ships, instant dialling goes from **56% to
  85%** — if the whole set fits, which on this handset it does not: at the 8191
  bytes it does take, the ~120 countries that fit give **50%**, against 0% with
  the local rules alone.

  It cannot make a number undialable. The length attached to a prefix is the
  maximum over every number type whose pattern that prefix could still grow
  into, so it is never shorter than a real number starting that way. Countries
  with genuinely open numbering never tighten and keep falling through to the
  `011*` timeout — a German landline is 5 to 15 digits and every Vorwahl reaches
  15, so Germany gets no benefit at all and is unchanged.

  The generator re-checks that at build time against all 1128 example numbers
  and **fails the build** rather than emit a rule that would dial one truncated.
  The handset caps the file at 8191 bytes, which is far less than every country
  needs, so only about 120 of them fit — see "The dial rules must fit in 8191
  bytes" below for which and why. Set the option to `false` for just the 12
  hand-written local rules.

- `611` — local echo test, on either line.
- A call inbound on a trunk rings that trunk's line button.

### The dial rules must fit in 8191 bytes

**The handset holds the whole dial plan in one 8191-byte buffer and throws away
anything longer** — not the excess rules, the entire file, leaving no auto-dial
at all, not even for local numbers. Read out of `usr/lib/libsip.so` in the
firmware (`rootfs288xx…sbn` is a plain squashfs; `unsquashfs` it):

```
CC_Config_setDialPlan                      ; sipcc/core/api/cc_config.c:124
    ldr  r3, 0x00001fff                    ; 8191
    cmp  r2, r3                            ; r2 = dial plan length
    ble  accept
    ...  "Setting NULL dialplan string (length [%d] is 0, or length is larger
          than maximum [%d])"               ; prints 0x2000 = 8192
    then: set a NULL dial plan -> "Loading Default Dialplan"

dp_init_template                           ; sipcc/core/submgr/dialplanint.c
    memset(dpLoadArea, 0, 0x1fff)          ; one static 8191-byte buffer
    memcpy(dpLoadArea, string, length)
```

Both of those log lines are behind debug flags that are off, so on the phone
this failure is completely silent: dialling simply waits for the timeout. The
generator therefore enforces the limit itself and **fails the build** rather
than emit a file the handset would discard.

Every country needs 117 KiB, so `perCountryDialRules` fits what it can, cheapest
country first: ~120 of the 215 countries that have rules, in ~7.9 KiB, taking
instant dialling from 0% to ~50% of libphonenumber's example numbers. Most
countries cost a single rule because all their numbers are one length; the
expensive ones are those whose length depends on the area code — Japan needs 143
rules and Pakistan 152, either of them as much as a hundred cheap countries —
and those are what gets dropped. Dropped countries still dial, on the `011*`
timeout. `perCountryDialRuleCountries` overrides the choice when the country you
call is one of the expensive ones.

Confirmed on the handset: at 7897 bytes (294 under the limit) a ten-digit number
sends on the last digit, and at 119608 bytes nothing auto-dials at all. So the
8191 above is the bound that matters, and it is on the file's own bytes.

A build that fits prints its numbers:

```
7897 bytes, 162 rules, 294 bytes spare; 96 countries left out as too expensive: +7 +20 …
```

#### Historical note, and a log line that lies

This was originally diagnosed as a race, wrongly, and the docs said so for a
while. Every config parse prints

```
config_parser_handle_dialplan_file : Unable to fetch DP file=[dialplan.xml].  Setting to default.
```

**including parses after which the dial rules demonstrably work.** The fetch is
asynchronous: the parse hands the request to the phone's download subsystem,
gives it ~100 ms to _accept_ it (not to deliver the file), logs that line when
it hasn't, and the file lands seconds later and is applied anyway. Do not
diagnose the dial plan from it.

None of the following ever mattered, so don't re-test them: where
`<dialTemplate>` sits in the config, whether a previous fetch left the file
cached, the locale blocks, restart versus full reset, the 11.7.1 → 14.4.1
firmware upgrade, or serving everything over HTTP instead of TFTP. That last one
turned out to be worth doing for its own sake, and is now on — see "Provisioning
goes over HTTP" above.

#### Reading the phone's log anyway

It is the right tool for other questions — it is how the KPML single-digit
INVITE was found — so: the web UI is enabled and `/FS/` serves the log files.

```bash
# on pbxvm
curl -s http://<phone-ip>/FS/messages
curl -s "http://<phone-ip>/CGI/Java/Serviceability?adapter=device.statistics.consolelog"
```

The log rotates on boot, so look in `/FS/messages.0` (and the `main_*.tar.gz`
archives listed on the console-log page) for anything older than the last few
minutes. Two practical notes: `/FS/` returns a 50-byte "not found" page for a
minute or two after a boot, and the only reliable test of whether the dial rules
are live is to dial a ten-digit number and see whether it sends on the last
digit.

`vacu.pbx.trunks.telnyx.outboundCallerId` is unset, so Telnyx picks the
connection's default caller ID. Set it to an E.164 number you own to override.

## Things that will need attention later

- `vacu.pbx.trunks.telnyx.signalingIps` is Telnyx's _US_ signalling pair from
  <https://sip.telnyx.com/>. If the connection moves region, or Telnyx
  renumbers, update it (inbound would still work via `line=yes`, but the
  `identify` would stop matching).
- No voicemail, no second handset, no CDR storage. All are additions to
  `hosts/pbxvm/asterisk.nix` rather than rework.
- `<loadInformation>` is absent from the XML unless `vacu.pbx.firmwareLoad` is
  set, so by default the phone keeps whatever firmware it has. See below for an
  upgrade.

## Upgrading the phone's firmware

The images come in a Cisco `.cop.sha512`, which is not redistributable and runs
to a few hundred MB, so they stay out of the repo and out of the nix store: they
are unpacked into `/srv/tftp` by hand for the upgrade and deleted afterwards.
`vacu.pbx.firmwareLoad` is the only declarative part.

A COP file is a Cisco signed object — a TLV header followed by a gzipped tar.
There is no header length to trust, so find where the payload starts:

```bash
# the offset of the gzip magic, which is where the tar begins
python3 -c 'd=open("cmterm-88xx-sip.14-4-1-0301-6.k4.cop.sha512","rb").read(8192)
print(next(i for i in range(len(d)-1) if d[i]==0x1f and d[i+1]==0x8b))'   # e.g. 428

tail -c +429 cmterm-*.cop.sha512 | gzip -dc | tar t      # look before extracting
```

Inside, `sip88xx.<version>.loads` is itself a signed file whose payload is an
INI listing one `[PLATFORM_n]` section per hardware variant. Match the phone to
its section using **Device information** in its web UI: this 8851 reports
`rootfs288xx…` and `sb2288xx…`, which is `[PLATFORM_2]`, so it fetches the
`288xx` images and ignores the others.

```bash
# on pbxvm, as root: unpack, and make it readable by the user atftpd drops to
tail -c +429 cmterm-*.cop.sha512 | gzip -dc | tar x -C /srv/tftp
chmod a+r /srv/tftp/*.sbn /srv/tftp/*.loads
```

Then set `vacu.pbx.firmwareLoad` to the load name (the `.loads` filename without
that extension), deploy, and restart the handset. It compares the name against
what it runs, fetches the images for its platform, writes them to flash and
reboots — several minutes, during which it is unusable and must not lose power.
Watch `journalctl -fu darkhttpd` for the `.sbn` transfers and the phone's
**Settings → Admin Settings → Status → Status messages** for progress.

This handset went 11.7.1 → 14.4.1 that way in about four minutes over TFTP,
fetching only its `[PLATFORM_2]` images: `rootfs288xx`, `kern288xx`, `ssb288xx`
and `sb2288xx`. Two things change afterwards that look like faults and are not —
the web UI reports **Service mode: On-premise** where 11.7 said _Enterprise_,
and the phone starts asking for `defaultheadsetconfig.json`, which 14.x wants
and this server does not have, so it joins the `.tlv` files as a harmless 404.

Afterwards, confirm the new version in the web UI, then **unset `firmwareLoad`,
redeploy, and delete the images** — a load named in the config whose files are
missing leaves the phone hunting for them on every boot, and these are the
largest files on the VM by two orders of magnitude:

```bash
# on pbxvm, once the handset reports the new load
cd /srv/tftp && sudo rm -f *.sbn *.loads *.rwb *.txt *.sh Ringlist-wb.xml
```
