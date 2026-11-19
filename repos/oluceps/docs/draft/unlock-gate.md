# unlock-gate: network-bound unlock for eihort (draft)

Status: draft, not yet deployed. Every "to be verified" item in this document
MUST be confirmed in VM tests before deployment.

## 0. Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 ([RFC 2119], [RFC 8174])
when, and only when, they appear in all capitals.

[RFC 2119]: https://www.rfc-editor.org/rfc/rfc2119
[RFC 8174]: https://www.rfc-editor.org/rfc/rfc8174

## 1. Goals and scope

### 1.1 Goals

1. Once eihort is **powered off, shut down, or removed**, its disk contents
   MUST NOT be decryptable using eihort alone, including by booting the
   original machine.
2. A planned reboot SHOULD unlock without human intervention.
3. An unplanned boot (power loss, watchdog reset, kernel panic, machine started
   by someone else) MUST require explicit user approval.
4. Compromise of any single remote node MUST NOT be sufficient to decrypt eihort.
5. When every network unlock path fails, a manual fallback that does not depend
   on the network MUST exist.

### 1.2 Threat model

The primary adversary is law-enforcement forensics: seizing hardware, imaging
disks offline, booting the original machine, operating inside the local
network, and possibly applying legal pressure to providers within or under the
influence of its jurisdiction.

### 1.3 Out of scope

This design provides no protection in the following cases; they need other
measures (see §10.2):

- Live forensics while running (keys already in memory).
- Coercion of the user.
- Simultaneous control of ≥2 gate nodes plus possession of eihort's disk.
- Evil maid after Secure Boot is reset, in the absence of TPM remote attestation.

## 2. Terminology

| Term | Meaning |
|---|---|
| client | The protected host that needs unlocking. Currently the only client is eihort |
| gate | A remote node running unlock-gate; acts as both Tang server and policy layer |
| nbde-agent | The Rust unlock client the client runs in its initrd (§7) |
| P | The random passphrase of LUKS keyslot 0, 64 bytes |
| JWE | The JWE file, produced by official clevis, that encrypts P |
| share | One sss share, protected by one gate's Tang exchange key |
| arm | A one-shot planned-reboot authorization issued by the running client |
| approval | A one-shot, time-windowed authorization signed by the user's security key (§6.6), or issued through ctl in an emergency |
| release | The gate performing ECMR for one `/rec` request and returning the result |
| budget | The release sources (arm or approval) currently available for a client on a gate |

## 3. Architecture

### 3.1 Nodes

| Role | Host | Public address | Mesh address |
|---|---|---|---|
| client | eihort | behind NAT (home broadband) | `fdcc::3` |
| gate | yidhra | `216.195.195.184`, `2a0f:1cc6:b225:0:c744:d4a4:9364:2971` | `fdcc::4` |
| gate | abhoth | `154.31.114.112`, `2403:18c0:1000:13a:343b:65ff:fe1b:7a0f` | `fdcc::5` |
| gate | nodens | `193.123.164.59`, `2603:c021:8025:648e:0:dc5b:117f:5225` | `fdcc::8` |

- A gate's id (`gateId`, the `aud` of signed messages) is its host name.
- The threshold MUST be 2-of-3, counted per gate (not per address).
- azasos (HKG) MUST NOT hold a share. Rationale: under this threat model it is
  the cheapest to compromise; including it as 2-of-4 lowers security, and as
  3-of-4 does not raise security while lowering availability.
- Gate nodes SHOULD belong to different providers and jurisdictions.

### 3.2 Components

```
eihort initrd
  systemd-cryptsetup@crypt-root ── keyfile = /run/nbde/key.sock (AF_UNIX)
                                        │
  nbde-agent (Rust, Type=notify) ◄──────┘
    sss t=2 → sss t=1 ×3 → tang
      └─ direct HTTP :7500 ────────────────► gate ×3
                                               unlock-gate (Go, embeds tang.go)
                                                 public :7500  /c/{client}/adv, /c/{client}/rec/{kid}
                                                 mesh   :7501  /v1/heartbeat, /v1/arm, /v1/disarm,
                                                               /v1/approve, /v1/status
                                                 ctl.sock      approve / deny / disarm / status
                                                 notify        Telegram Bot
running eihort
  clevis (bind only), unlock-agent (heartbeat), eihort-reboot (arm) ──── mesh ────► gate ×3
user's laptop (mesh node)
  unlock-gate approve (sshsig, one security-key touch) ─────────────── mesh ────► gate ×3
```

### 3.3 Layer responsibilities

| Layer | Component | Responsibility |
|---|---|---|
| Storage | LUKS2 (nvme), `/persist/keys/*` | Data encryption |
| Encapsulation | official clevis (bind), nbde-agent (decrypt) | P ↔ JWE; sss threshold; tang pin |
| Exchange | Tang protocol (ECMR), tang.go | Blinded key exchange; the server neither holds nor sees shares |
| Policy | unlock-gate | Decides whether to release |
| Delivery | systemd-cryptsetup AF_UNIX keyfile | Hands P to LUKS |
| Transport | plain HTTP / mesh | Reachability only; **security MUST NOT depend on the transport** |

## 4. Key hierarchy

```
recovery passphrase (offline, paper) ─► LUKS keyslot 1 ─┐
                                                         ├─► LUKS volume key ─► nvme (/persist /var /nix)
P (64 random bytes) ─────────────────► LUKS keyslot 0 ─┘                         └─► /persist/keys/pool0-* ─► pool0
  ▲
  └─ JWE: CEK split with sss; each share protected by one gate's Tang exchange key
```

- P MUST be generated by a CSPRNG, MUST be 64 bytes long, and MUST NOT be
  persisted in plaintext on any medium.
- The recovery passphrase MUST use an argon2id keyslot, MUST be kept offline,
  and MUST NOT be stored on any networked device.
- pool0's keys MUST live in `/persist/keys/` with mode `root:root 0400`.
- The LUKS header SHOULD be backed up offline.

## 5. Binding (official clevis)

Binding MUST use official clevis so that the JWE format is produced by the
reference implementation. nbde-agent MUST NOT implement encryption or binding.

### 5.1 Pin structure

```json
{
  "t": 2,
  "pins": { "sss": [
    { "t": 1, "pins": { "tang": [
      { "url": "http://216.195.195.184:7500/c/eihort",                        "thp": "<yidhra>" },
      { "url": "http://[2a0f:1cc6:b225:0:c744:d4a4:9364:2971]:7500/c/eihort",  "thp": "<yidhra>" } ] } },
    { "t": 1, "pins": { "tang": [
      { "url": "http://154.31.114.112:7500/c/eihort",                         "thp": "<abhoth>" },
      { "url": "http://[2403:18c0:1000:13a:343b:65ff:fe1b:7a0f]:7500/c/eihort","thp": "<abhoth>" } ] } },
    { "t": 1, "pins": { "tang": [
      { "url": "http://193.123.164.59:7500/c/eihort",                         "thp": "<nodens>" },
      { "url": "http://[2603:c021:8025:648e:0:dc5b:117f:5225]:7500/c/eihort",  "thp": "<nodens>" } ] } }
  ] }
}
```

- The outer sss MUST count gates; all addresses of one gate MUST be placed in
  the same inner `t=1` sss. Flattening several addresses into the outer sss
  MUST NOT be done, as a single gate could then meet the threshold.
- Every tang pin MUST specify `thp` explicitly. `thp` MUST be obtained over a
  trusted channel (reading it after SSH login to the gate) and MUST NOT rely on
  trust-on-first-use of an adv fetched over public HTTP.
- URLs MUST use IP literals; the initrd MUST NOT depend on DNS.

### 5.2 Binding procedure (performed while the client is running)

1. On each gate, read the `thp` of that client's dedicated Tang signing key.
2. Generate P: `head -c 64 /dev/urandom`, kept only on ramfs/tmpfs.
3. `clevis encrypt sss '<§5.1 config>' < P > /persist/keys/crypt-root.jwe`.
4. `cryptsetup luksAddKey --key-slot 0 <dev>`, with P as the new passphrase.
5. After `approve` on ≥2 gates, run `nbde-agent check /persist/keys/crypt-root.jwe`;
   it MUST report the threshold as met, and the digest MUST match the first
   8 bytes of `sha256(P)`.
6. Destroy the temporary copy of P.
7. Reinstall the bootloader so the JWE enters the initrd (§7.6).

### 5.3 Confidentiality of the JWE

The JWE alone cannot be decrypted, but its holder can race a `/rec` while a
budget is valid, obtaining a share or exhausting an arm. Therefore:

- The JWE MUST NOT enter the public repository or the Nix store.
- The JWE MUST enter the initrd through `boot.initrd.secrets` as a runtime
  path (string).
- The JWE being present on the ESP is acceptable; an adversary able to read
  the ESP already has physical access.

## 6. unlock-gate specification

### 6.1 Configuration (declared in Nix, not secret)

```nix
services.unlock-gate = {
  enable = true;
  gateId = "yidhra";             # the host name
  publicAddresses = [ "::" ];    # port publicPort = 7500; "::" also accepts IPv4
  meshAddresses = [ "fdcc::4" ]; # port meshPort = 7501; the gate's mesh anchor address
  meshInterface = "vxlan-mesh";  # the mesh port is opened only here
  clients.eihort = {
    agentPublicKey = "<Ed25519 public key, base64url>";
    allowFrom = [ ];            # OPTIONAL, list of CIDRs; empty means unrestricted
    approvers = [               # any one of these may sign an approval
      "sk-ssh-ed25519@openssh.com AAAA…"
      "sk-ssh-ed25519@openssh.com AAAA…"
    ];
  };
  requireSecurityKey = true;    # approvers MUST be sk-* keys; tests MAY disable
  telegram.tokenFile = config.vaultix.secrets.unlock-gate-tg.path;  # read as a systemd credential
  telegram.chatId = "<chat id>";
};
```

- Each client MUST have its own dedicated Tang key set, stored in
  `/var/lib/unlock-gate/<client>/`.
- A gate MUST support multiple clients and MUST strictly isolate keys and
  policy by the `{client}` in the URL.

### 6.2 State

| State | Storage | Lifetime |
|---|---|---|
| Tang keys | disk, `/var/lib/unlock-gate/<client>/`, `0700` | persistent |
| Client public keys, policy | Nix configuration | persistent |
| arm, approval, nonce cache, heartbeat, attempt log | **memory** | process lifetime |
| Audit log | journald | per system retention policy |

- arm and approval MUST exist only in memory. A gate process restart MUST
  invalidate every budget (fail closed).

### 6.3 Public interface (Tang-compatible)

Listens on `publicListen`, plain HTTP. Both official clevis (binding and
interop tests) and nbde-agent use this interface.

| Method | Path | Behavior |
|---|---|---|
| GET | `/c/{client}/adv` | Returns that client's adv (JWS) |
| GET | `/c/{client}/adv/{thp}` | Returns the adv signed by the given signing key |
| POST | `/c/{client}/rec/{kid}` | §6.7 decision; 200 + JWK, or 403 |

- An unknown `{client}` or `{kid}` MUST return 404.
- A 403 response body SHOULD be `{"error":"not_authorized"}` and MUST NOT
  reveal anything else.
- Request bodies MUST be limited to 8 KiB; read, write, and idle timeouts
  SHOULD be 10 s, 10 s, and 30 s respectively.
- The gate MUST rate-limit by source IP; the RECOMMENDED value is 30 `/rec`
  per minute.
- The gate MUST decide immediately and MUST NOT long-poll `/rec`.

### 6.4 Mesh interface (for the running client)

Listens on `meshListen`. The firewall MUST allow this port only on the mesh
interface.

| Method | Path | Body | Response |
|---|---|---|---|
| POST | `/v1/heartbeat` | JWS (§6.5, `typ=heartbeat`) | 204 / 401 / 409 |
| POST | `/v1/arm` | JWS (`typ=arm`) | 204 / 401 / 409 |
| POST | `/v1/disarm` | JWS (`typ=disarm`) | 204 / 401 / 409 |
| POST | `/v1/approve` | approval token (§6.6) | 204 / 401 / 409 |
| GET | `/v1/status?client=C` | — | 200 + JSON (§6.8 `status`) |

- 401: signature, `aud`, `client`, or `typ` validation failed.
- 409: repeated nonce, `seq` regression, or `iat` outside tolerance.
- `/v1/status` is unauthenticated and therefore reachable by every mesh node;
  it MUST NOT contain the JWE or any secret.

### 6.5 Signed messages

Format: JWS Compact Serialization; `alg` MUST be `EdDSA` (Ed25519) and the
`typ` header MUST be `unlock-gate+jws`.

| Field | Type | Applies to | Requirement |
|---|---|---|---|
| `v` | int | all | MUST be 1 |
| `typ` | string | all | `heartbeat` / `arm` / `disarm` |
| `aud` | string | all | MUST equal the receiver's `gateId` |
| `client` | string | all | MUST be a configured client |
| `boot_id` | string | all | The client's `/proc/sys/kernel/random/boot_id` |
| `iat` | int | all | Unix seconds; the gate MUST reject messages more than 120 s from its local clock |
| `seq` | uint64 | heartbeat | MUST strictly increase within one `boot_id` |
| `nonce` | string | arm, disarm | 16 bytes, base64url; the gate MUST reject a repeated nonce within 240 s |
| `ttl` | int | arm | seconds; MUST be ≤ 600 |

- An arm's expiry MUST be computed as the gate's receive time plus
  `min(ttl, 600)`, and MUST NOT be computed from the client's clock.
- At most one valid arm MUST exist per client at a time; a new arm MUST
  replace the old one.
- Heartbeats MUST NOT affect any release decision; they are for alerting only.
  An arm MUST NOT be conditional on heartbeat freshness.

### 6.6 Approval tokens

An approval is a JSON document signed with OpenSSH's `sshsig` format
(`ssh-keygen -Y sign`), so it can be produced by a FIDO security key with one
touch and sent to every gate.

| Field | Type | Requirement |
|---|---|---|
| `v` | int | MUST be 1 |
| `typ` | string | `approve` or `deny` |
| `client` | string | MUST be a configured client |
| `gates` | string[] | MUST contain the receiver's `gateId` |
| `iat` | int | Unix seconds; same 120 s tolerance as §6.5 |
| `nonce` | string | 16 bytes, base64url; same 240 s replay cache as §6.5 |
| `window` | int | `approve` only; seconds, MUST be ≤ 900 |
| `from` | string[] | OPTIONAL CIDRs; the approval only releases to matching sources |

Body of `POST /v1/approve`: `{"message": "<base64url JSON>", "signature": "<armored sshsig>"}`.

- The signature namespace MUST be `nbde-unlock-gate@v1`; the hash MUST be
  `sha512` or `sha256`.
- The signing key MUST be one of the client's `approvers`. When
  `requireSecurityKey` is set, approvers MUST be `sk-*` keys and the signature
  MUST carry the user-presence flag.
- The gate MUST verify the signature itself and MUST NOT execute `ssh-keygen`
  or consult sshd configuration.
- The approval's expiry MUST be computed from the gate's receive time.
  A `deny` MUST clear the approval and grace period.
- The laptop-side `unlock-gate approve` command fetches `/v1/status` from all
  gates, shows them side by side, asks for confirmation, signs once with
  `ssh-keygen -Y sign`, and posts the same token to every gate.

### 6.7 `/rec` decision

```
on POST /c/{client}/rec/{kid}
  1. validate client, kid, body format; failure → 404 / 400
  2. if allowFrom is non-empty and the source address does not match → 403, log
  3. if a valid arm exists → release, consume the arm, reason "arm"
  4. else if a valid approval exists and (no --from set, or the source matches)
     → release, consume the approval, reason "approval"
  5. else if within a grace period and the source equals the grace-period source
     → release, reason "grace"
  6. else → 403, record the attempt, notify per §6.9
```

- One arm or approval MUST produce exactly one budget-counted release,
  regardless of whether requests come over IPv4 or IPv6.
- After a release the gate MAY open a grace period: for 60 s, `/rec` from the
  **same source address** continues to be released, tolerating a response lost
  in transit. A grace period MUST NOT extend across source addresses; a
  request from another source during it is refused with reason
  "released to another source".
- Every release and denial MUST be written to the audit log: time, client,
  kid, source address, result, reason.

### 6.8 Management interface

- Socket: `/run/unlock-gate/ctl.sock`, `0600 root:root`; the gate MUST verify
  via `SO_PEERCRED` that the peer uid is 0.
- Protocol: one JSON request and one JSON response per line.
  CLI: `unlock-gate ctl <command>`.

| Command | Effect |
|---|---|
| `status [--client C]` | Heartbeat (last time, `boot_id`, `seq`), arm, approval, last 20 attempts |
| `approve --client C [--window 300] [--from CIDR]` | Create an approval; `window` MUST be ≤ 900 s |
| `deny --client C` | Clear approval and grace period |
| `disarm --client C` | Clear arm |

- Approvals MUST only be created by a valid approval token (§6.6) or through
  ctl. The gate MUST NOT offer any other network path to create one. ctl is the
  emergency path for when the mesh or the laptop is unavailable.

### 6.9 Notifications

| Event | Trigger |
|---|---|
| `heartbeat_lost` | No valid heartbeat for more than 180 s |
| `heartbeat_resumed` | Recovery after loss, with old and new `boot_id` |
| `unlock_denied` | A 403; MUST notify at most once per client per 10 minutes. A 403 to another source while a grace period is open (the losing address family of a release) MUST NOT notify |
| `unlock_released` | Every budget-counted release, with reason |
| `arm_received` | A valid arm was received |
| `approval_received` | A valid approval or deny token, or a ctl approve/deny |

- Notifications SHOULD contain only gate, client, event, time, and source
  address; they MUST NOT contain the JWE or any secret.

### 6.10 Process hardening

- The gate SHOULD run as non-root, accessing Tang keys through
  `StateDirectory` and providing `ctl.sock` through `RuntimeDirectory`. If
  `DynamicUser` is used, the ctl peer check MUST be adjusted accordingly (TBD).
- The gate SHOULD enable `ProtectSystem=strict`, `PrivateTmp`,
  `NoNewPrivileges`, `RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX`, and
  `MemoryDenyWriteExecute`.

## 7. Client (eihort) specification

### 7.1 Runtime components

| Component | Behavior |
|---|---|
| `unlock-agent.timer/service` | Sends a heartbeat to every gate over the mesh every 60 s; failures are only logged |
| `eihort-reboot` | Sends an arm to every gate; runs `systemctl reboot` when **successes ≥ 2**, otherwise MUST abort with a non-zero exit |
| agent private key | `/persist/keys/unlock-agent.ed25519`, `root:root 0400`; public key goes into the gate configuration |

- An arm MUST only be produced by the user explicitly running `eihort-reboot`.
  An arm MUST NOT be produced by shutdown/reboot hooks, UPS events, the power
  button, the watchdog, or any automated process.
- `eihort-reboot` MUST require root.

### 7.2 nbde-agent: interface

A single binary with two modes:

```
nbde-agent [--config <path>]     # daemon mode, default config /etc/nbde/agent.toml
nbde-agent check <jwe>           # diagnostic mode
```

- Argument parsing MUST use only `std::env::args` and MUST NOT pull in an
  argument-parsing library.
- Daemon mode is started by systemd as `Type=notify`; it binds its own
  listening socket and sends `READY=1` once bound (§7.5). Socket activation is
  not used: turning the integer fd from `LISTEN_FDS` into a socket requires
  `unsafe`, which conflicts with §8.1.
- `check` mode runs the full unlock flow (§7.4), prints the result for each
  pin and address and the threshold verdict, and prints the first 8 bytes of
  `sha256(P)`. `check` MUST NOT print P, the CEK, shares, or Z.
- nbde-agent MUST NOT offer encrypt, bind, decrypt-to-stdout, or a local
  control socket.

### 7.3 nbde-agent: configuration

```toml
attempt_timeout_secs = 30
retry_interval_secs  = 10
deadline_secs        = 900
socket               = "/run/nbde/key.sock"   # default
console              = true                   # write to /dev/console; default true

[[volume]]
name = "crypt-root"
jwe  = "/etc/nbde/crypt-root.jwe"
```

- The configuration MUST NOT contain secrets. All gate addresses and `thp`
  values come from the JWE itself.
- Unknown fields MUST cause startup to fail.

### 7.4 nbde-agent: decryption behavior

**Supported JWE subset**

- Only clevis `sss` and `tang` pins are supported; other pins (`tpm2`, `null`,
  `pkcs11`, etc.) MUST be rejected.
- sss nesting depth MUST be ≤ 4; total JWE size MUST be ≤ 64 KiB.
- The format MUST be byte-for-byte compatible with official clevis output, as
  defined by test vectors produced with the official tools (§11).

**tang pin**

1. Take the exchange public key S by `kid` from the adv embedded in the JWE
   header. Decryption MUST NOT request `/adv`.
2. Generate an ephemeral scalar e and send X = epk + e·G to `{url}/rec/{kid}`.
3. On receiving Y, compute Z = Y − e·S, derive the content key per RFC 7518
   §4.6 (ECDH-ES Concat KDF), and decrypt.
4. Curve and algorithms are taken from the JWE header; the implementation MUST
   reject algorithms the header does not declare or that are unsupported.

**sss pin**

- Child pins MUST run concurrently; once successes reach `t`, the
  implementation MUST combine immediately and abandon the remaining requests.
- When failures exceed `n − t`, the round MUST be judged failed and retried.
- Malicious parameters (`t = 0`, `t > n`, duplicate share coordinates, values
  outside the modulus) MUST be rejected.

**HTTP**

- HTTP/1.1 cleartext only; MUST NOT follow redirects; MUST NOT read proxy
  environment variables; response bodies MUST be limited to 8 KiB; the
  per-request timeout is `attempt_timeout_secs`.
- Any status other than 200 MUST be treated as that pin failing this round;
  403 MUST be recorded as `denied`.

**Retry**

- After each failed round, wait `retry_interval_secs` and retry, until success
  or `deadline_secs` is reached.
- Each round MUST generate a fresh e.

### 7.5 nbde-agent: AF_UNIX delivery

When systemd-cryptsetup recognizes the keyfile path as an AF_UNIX stream
socket, it connects and reads until EOF; its client socket is bound to the
abstract address `\0<random>/cryptsetup/<volume>`.

- nbde-agent MUST verify via `SO_PEERCRED` that the peer uid is 0.
- nbde-agent MUST parse `<volume>` from the peer's abstract address and
  deliver only to the configured volume of that name; if the address format
  does not match or the volume is unknown, it MUST close the connection
  immediately without writing any data.
- If P is not ready when a connection arrives, nbde-agent SHOULD hold the
  connection until P is ready or the deadline is reached.
- The delivered content MUST be the raw bytes of P, with no newline; after
  writing, the connection MUST be closed and P zeroed immediately.
- At the deadline, nbde-agent MUST close all held connections without writing
  data and then exit with failure, sending systemd-cryptsetup to its
  passphrase prompt.
- nbde-agent SHOULD begin network unlock as soon as the initrd starts it,
  rather than waiting for the first connection, to overlap network wait time.
- The socket file MUST be `0600` and its directory MUST be `0700`; at startup
  it MAY replace a stale socket file and MUST NOT replace a non-socket file.
  The socket file SHOULD be removed on process exit.
- Each volume's P MUST be delivered only once; later requests for the same
  volume MUST be refused (falling through to the passphrase prompt).

### 7.6 initrd integration

```nix
boot.initrd = {
  systemd.enable = true;
  systemd.network.enable = true;            # eno1: IPv4 DHCP + IPv6 SLAAC
  secrets."/etc/nbde/crypt-root.jwe" = "/persist/keys/crypt-root.jwe";   # string path
  luks.devices.crypt-root = {
    device = "/dev/disk/by-uuid/<uuid>";
    keyFile = "/run/nbde/key.sock";
    keyFileTimeout = 900;                   # behavior to be verified (§12.1)
  };
  systemd.services.nbde-agent = {
    # Start early; the agent's own retry handles a network that is not up yet,
    # so it is not ordered after wait-online.
    # Type=notify: start-up completes only once the socket is bound, and
    # cryptsetup is ordered after it.
    wantedBy = [ "systemd-cryptsetup@crypt\\x2droot.service" ];
    before = [ "systemd-cryptsetup@crypt\\x2droot.service" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "main";
      ExecStart = "${pkgs.nbde-agent}/bin/nbde-agent";
    };
  };
  systemd.storePaths = [ "${pkgs.nbde-agent}/bin/nbde-agent" ];
  network.ssh.enable = true;                # fallback; reachable only from the LAN
};
```

- The initrd MUST NOT contain clevis, jose, curl, DNS dependencies, CA
  certificates, proxy credentials, or mesh credentials.
- The initrd sshd MUST accept only the user's public keys and SHOULD be
  reachable only from the LAN.

### 7.7 Fallback

| Action | Method |
|---|---|
| Abandon network unlock | via initrd ssh: `systemctl stop nbde-agent.service` |
| Enter the recovery passphrase | `systemd-tty-ask-password-agent` (initrd ssh) or the BMC console |

### 7.8 Prerequisites

The following MUST hold before enabling this design:

1. The nvme root partition is LUKS2; `/persist`, `/var`, and `/nix` all live on it.
2. Both swaps (nvme partition and SATA DOM) MUST use a random per-boot key;
   `resumeDevice` MUST be removed.
3. A BIOS administrator password is set; Secure Boot is in user mode with
   setup mode disabled.
4. The BMC is network-isolated and its default credentials have been changed.
5. The recovery passphrase is stored offline and has been tested to work.

## 8. nbde-agent implementation constraints

### 8.1 General

- The implementation language MUST be Rust; the crate MUST declare
  `#![forbid(unsafe_code)]` and make system calls through `rustix`'s safe
  wrappers.
- The implementation MUST NOT use `std::process::Command` or execute external
  programs in any way.
- The implementation MUST be synchronous (standard threads) and MUST NOT pull
  in an async runtime.
- The binary SHOULD be statically linked.

### 8.2 Memory hygiene

- At startup the process MUST run, in order: `mlockall(MCL_CURRENT | MCL_FUTURE)`,
  `prctl(PR_SET_DUMPABLE, 0)`, `setrlimit(RLIMIT_CORE, 0)`. Any failure MUST
  abort startup.
- P, the CEK, shares, Z, and the ephemeral scalar e MUST be held in `secrecy`
  secret types or in types implementing `ZeroizeOnDrop`.
- Secret buffers SHOULD be preallocated with fixed capacity, so that growth
  does not leave unzeroed copies behind.
- Per-page `mprotect` schemes such as `memsafe` are NOT RECOMMENDED: they
  cannot cover copies made inside dependencies, and process-wide `mlockall`
  already covers the swap-out risk.

### 8.3 Error handling

- Error types MUST be defined with `snafu`, split per module, and carry
  context (volume name, gate URL, stage).
- An error's `Display`/`Debug` MUST NOT contain secrets and MUST NOT echo HTTP
  response bodies.
- User-facing status MUST be emitted on three channels: `/dev/console`,
  `sd_notify` `STATUS=`, and the journal.

### 8.4 Dependencies

| Purpose | crate |
|---|---|
| Elliptic curves | `p521` (`arithmetic`, `jwk`) |
| Symmetric encryption and KDF | `aes-gcm`, `sha2` |
| sss modular arithmetic | a big-integer library, chosen once §12.1 item 1 confirms the format |
| Secrets and zeroing | `secrecy`, `zeroize` |
| Errors | `snafu` |
| Serialization | `serde`, `serde_json`, `toml`, `base64ct` |
| System calls | `rustix` |
| HTTP | `ureq` (default features off, no TLS) or a self-written minimal HTTP/1.1 client |

### 8.5 Modules and size estimate

| Module | Responsibility | Estimated lines |
|---|---|---|
| `jose` | compact JWE, Concat KDF, A256GCM, JWK | 200–300 |
| `pin::tang` | ECMR blinded exchange | 150–200 |
| `pin::sss` | threshold combination, recursive dispatch, concurrency | 200–250 |
| `http` | minimal HTTP client | 50–150 |
| `sink` | AF_UNIX delivery, peer verification | 120–180 |
| `config` | TOML configuration | 80–120 |
| `agent` | state machine, retry, deadline, multiple volumes | 200–300 |
| `ui` | console, sd_notify, journal | 60–100 |
| `secret` | process hardening, secret types | 40–60 |
| `main`, errors | | 100–150 |
| **Total** | | **about 1,200–1,800**, of which about 700–1,000 security-critical |

## 9. Interaction flows

### 9.1 Planned reboot

```
user: sudo eihort-reboot
  unlock-agent ─ POST /v1/arm ×3 (mesh) ─► successes ≥ 2 ? reboot : abort
initrd: nbde-agent ─ POST /c/eihort/rec/{kid} (HTTP, concurrent) ─► arm present → 200, arm consumed
        2 shares collected → P → handed to systemd-cryptsetup via key.sock → unlocked
gate: notify unlock_released(arm)
```

### 9.2 Unplanned boot

```
initrd: nbde-agent ─ POST /rec ─► 403 (gate logs and notifies unlock_denied)
        console: yidhra denied / abhoth denied / nodens unreachable; retry every 10 s
user: receives notification → unlock-gate approve --client eihort on the laptop
      → status from all gates shown side by side (source, time, heartbeat)
      → confirm → one security-key touch → token posted to every gate over the mesh
      (emergency: ssh to ≥2 gates, unlock-gate ctl approve --client eihort)
initrd: next round → 200 ×2 → unlocked
```

The user MUST approve only when they can explain that boot; if the source
address is not what they expect, they MUST NOT approve.

### 9.3 Failure

```
fewer than 2 shares before the deadline → nbde-agent closes connections and exits → passphrase prompt
  → user enters the recovery passphrase via initrd ssh or the BMC
```

## 10. Operations and security

### 10.1 Operations

| Operation | Steps |
|---|---|
| Tang key rotation | Generate a new key → hide the old key from adv but keep accepting `/rec` for it → client re-runs §5.2 → delete the old key |
| Gate public IP change | Re-run §5.2 while the client is running |
| Gate loses its Tang keys | Client running: re-run §5.2 with the new `thp`; client down: the remaining 2 gates can still unlock |
| Suspected gate compromise | Immediately, while the client is running: replace that gate's pin, generate a new P, `luksKillSlot` the old slot 0 |
| Adding a gate | Re-run §5.2; a threshold change MUST re-evaluate §3.1 |

### 10.2 Secret inventory and residual risk

| Secret | Location | Consequence of leaking it alone |
|---|---|---|
| LUKS volume key | header (wrapped); kernel memory at runtime | Direct decryption |
| recovery passphrase | offline, paper | Direct decryption |
| P | inside the JWE; briefly in nbde-agent memory during unlock | Direct decryption |
| JWE | ESP (initrd) | None; but can race a release while a budget is valid |
| Tang private keys | each gate's disk | None; needs another gate plus the JWE |
| agent private key | `/persist` (inside FDE) | Can issue arms; only obtainable while the client runs |
| approver key | the user's FIDO security key | Can sign approvals (one touch each); still needs the JWE |
| gate ctl access (SSH root) | the user's SSH keys | Can create approvals; still needs the JWE |
| Telegram token | gate (vaultix) | Can forge or intercept notifications |

Minimum conditions for obtaining P: the JWE, plus one of: (a) Tang private
keys or ctl access on ≥2 gates, or the approver key; (b) racing a request while an arm or approval
is valid.

| Residual risk | Mitigation |
|---|---|
| Live forensics while running | No auto-login; `intel_iommu=on`; usbguard; chassis intrusion detection; BMC isolation |
| Evil maid (initrd replaced after Secure Boot reset) | BIOS password; approve only explainable boots; MAY later add a TPM quote |
| ≥2 gates compromised + disk | Spread providers and jurisdictions; monitor gate integrity |
| Racing an approval window | Short, one-shot windows; MAY use `--from` |
| Implementation flaws in the custom client | Implement only the decryption path; interop and attack tests are a merge prerequisite (§11) |

### 10.3 Privacy

- Public HTTP exposes: the client's boot time, the target gate addresses, and
  a constant `kid` (which links boots together). The blinded JWK leaks
  nothing; active tampering only causes unlock failure.
- Heartbeats and arms travel over the mesh and are not exposed publicly.
- Telegram can see notification contents, hence the minimization required by
  §6.9.

## 11. Test plan

All of the following tests MUST pass before merging.

| Category | Cases |
|---|---|
| Format interop | Test vectors produced with official clevis + tang: single tang, sss, nested sss; nbde-agent MUST decrypt all correctly |
| Server interop | Official clevis bind/decrypt against unlock-gate; the `/c/{client}` path prefix |
| Normal flow | arm unlocks automatically; without an arm, 403 → approve → unlock |
| Threshold | Fails with 1 gate reachable; succeeds with 2; one gate's IPv4 and IPv6 MUST NOT count as 2 shares |
| Budget | arm is one-shot; approval is one-shot; grace period is same-source only; budget is invalidated after gate restart |
| Signed messages | Wrong `aud`/`client`, repeated nonce, `seq` regression, `iat` out of range, `ttl` > 600 |
| Parsing attacks | Truncated JWE, oversized JWE, unknown pin, excessive nesting, `t=0`, `t>n`, duplicate coordinates, oversized response |
| Cryptographic tampering | Modified `y` → decryption fails with no leak; `kid` mismatch; adv replaced during bind → `thp` check fails |
| AF_UNIX | Non-zero peer uid refused; mismatched volume refused; connection held while P is not ready; closed with fallback after deadline |
| Memory hygiene | `VmLck` in `/proc/<pid>/status` is non-zero; `dumpable` is 0; `check` output contains no secrets |
| initrd | Fallback passphrase prompt; `systemctl stop` aborts; agent has exited after switch-root |
| Network | IPv4 only, IPv6 only, gate port unreachable |

## 12. Open items and future work

### 12.1 To be verified

1. ~~Format details of official clevis JWEs~~: resolved, see the nbde
   repository's `docs/clevis-format.md` (based on the clevis 22 / jose /
   tang 15 sources and test vectors produced with the official tools).
2. ~~Whether clevis tang URLs support a path prefix~~: resolved, they do
   (`$url/adv/$thp` and `$url/rec/$kid` are plain string concatenation).
3. ~~Exact format of systemd-cryptsetup's peer abstract address~~: resolved
   (VM test `vm-cryptsetup-socket`, systemd 261.2). Observed as
   `\0<16 lowercase hex characters>/cryptsetup/<volume>`, with peer uid 0.
4. Holding the connection while P is not ready: **partially resolved**.
   Observed that systemd-cryptsetup blocks and waits (unlocked successfully
   after a 20 s delay, with a single connection and no passphrase prompt in
   between); the wait limit and the semantics of `keyFileTimeout` with a
   socket remain to be verified.
5. ~~When the agent closes the connection without writing data~~: resolved.
   systemd-cryptsetup treats it as a wrong key ("Failed to activate with key
   file … (Key data incorrect?)"), goes **immediately** to the passphrase
   prompt, and does not reconnect to the socket; writing a wrong key behaves
   the same.
6. ~~Unit ordering in the NixOS systemd initrd~~: resolved (nbde repository
   `vm-initrd` test, root on LUKS). In the `boot.initrd.nbde` module, a
   `Type=notify` agent ordered before `systemd-cryptsetup@` works; the first
   round fails while the network is not up and a retry then succeeds; after
   tang recovers it unlocks within the deadline; with everything unreachable
   the initrd reaches the passphrase prompt and boots with the recovery
   passphrase. Note: qemu-vm sets `boot.initrd.luks.devices` to empty with
   `mkVMOverride`, so the test must restate the full entry at the same
   priority; the module detects an overridden `keyFile` with an assertion.
7. `boot.initrd.secrets` string paths: **partially resolved**. In `vm-initrd`
   they are injected into the initrd correctly by systemd-boot's
   `switch-to-configuration boot`; behavior under lanzaboote remains to be
   verified on eihort.
8. Actual IPv4 and IPv6 reachability from the home network (bypassing
   sing-box) to `:7500` on all three gates.

### 12.2 Future work (out of scope for this draft)

- TPM remote attestation: the initrd submits a PCR 7/4 quote before `/rec`,
  and the gate refuses abnormal boot states based on it. The TPM MUST NOT be
  used to seal P.
- Better approval UX (e.g. WebAuthn). Before introducing it, phishing and
  hosted-page tampering risks MUST be re-evaluated.
- Runbooks for in-place nvme encryption and per-disk LUKS migration of pool0.

## 13. Implementation status (2026-11-19)

### 13.1 Done (nbde repository)

| Component | Status |
|---|---|
| nbde-agent: jose, tang/sss pins, HTTP, AF_UNIX delivery, daemon mode, check mode, status output | Done, 61 unit tests |
| NixOS module `boot.initrd.nbde` | Done |
| unlock-gate (Go, `gate/`, tang.go from the `oluceps/tang.go` `fix/audit-findings` branch): Tang-compatible `/adv` and `/rec` with the §6.7 decision, signed heartbeat/arm/disarm, sshsig approval tokens, `/v1/status`, root-only ctl socket, Telegram notifications, rate limiting, in-memory state | Done, 24 unit tests |
| unlock-gate CLI: `serve`, `ctl`, `send` (eihort side), `approve`/`deny` (laptop side; several approver keys tried in order), `agent-key` | Done |
| NixOS modules `services.unlock-gate`, `services.unlock-agent` (heartbeat timer, `<host>-reboot`), `programs.unlock-approve` | Done |
| VM tests `vm-agent`, `vm-check`, `vm-daemon`, `vm-cryptsetup-socket`, `vm-initrd`, `vm-gate`, `vm-gate-initrd` | All pass |
| Interop with official clevis 22 / tang 15, and sshsig with OpenSSH `ssh-keygen -Y sign` | Verified |

`vm-gate-initrd` covers the §9 flows: root on LUKS bound 2-of-2 to two
unlock-gates; a planned reboot unlocks through the arm; an unplanned boot is
refused in the initrd until the approver signs on a third node, then unlocks.

Bug found while integrating: nbde-agent sent `/rec` bodies without
`"alg":"ECMR"`. tangd accepts that and tang.go does not. Fixed on both sides:
the agent now sends what clevis sends, and the gate adds the member when it
is missing.

### 13.2 Deployment (2026-11-19)

- Gates yidhra, abhoth and nodens run unlock-gate; the mesh API listens only
  on each gate's anchor address. eihort sends heartbeats and has
  `eihort-reboot`; the approver runs on hastur with either security key.
- eihort's root is bound 2-of-3 (§5.1 with the host names); `nbde-agent
  check` recovered P after a real security-key approval (PIN and touch).
- A planned reboot through `eihort-reboot` unlocked in the initrd on the
  second attempt, about 11 s after boot: the first attempt ran before the
  network was up. The gates saw eihort's home addresses, so the initrd
  reaches them directly; one address family won on each gate and the other
  was refused without an alert.
- Telegram notifications were sent without errors; receipt in the chat is
  still to be confirmed.

### 13.2.1 Not done

- The unplanned-boot flow (refused, then approved from hastur) has only run
  in the VM test, not on eihort.
- After the first deployment, abhoth's unlock-gate unit did not start until
  started by hand; whether it starts on its own at boot is unconfirmed.

### 13.3 Known limitations and to-dos

- nbde-agent does not keep a share across retry rounds. If one gate releases
  through its arm while the other is unreachable for longer than the 60 s
  grace period, the arm is spent and the boot needs an approval.
- `crate-audit` cannot run because the GitHub API token is invalid (HTTP 401);
  after fixing nix's access-tokens, run `nix flake update` and `nix flake check`.
- The agent's first attempt often fails because the network is not up yet;
  the default `retryInterval = 10` makes a normal boot wait about 10 s longer.
  A backoff starting with a short interval would fix this.
- §12.1 item 7: eihort boots with plain systemd-boot. Before the secureboot
  (lanzaboote) import comes back, initrd secrets under lanzaboote must be
  verified.
- §7.8 prerequisites: nvme FDE and random swap keys are done; BIOS/BMC
  hardening is not.
